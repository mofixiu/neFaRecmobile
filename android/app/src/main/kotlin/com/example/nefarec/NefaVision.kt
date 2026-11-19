package com.example.nefarec

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.pdf.PdfRenderer
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import androidx.exifinterface.media.ExifInterface
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max

/**
 * On-device text recognition for neFaRec on Android, matching the iOS
 * `nefarec/vision` channel. ML Kit's bundled Latin model, so nothing is
 * uploaded and it works offline. Body pose stays iPhone-only.
 */
object NefaVision {
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val recognizer by lazy { TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS) }

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "nefarec/vision").setMethodCallHandler { call, result ->
            val path = call.argument<String>("path")
            if (path == null) {
                result.error("args", "Missing file path.", null)
                return@setMethodCallHandler
            }
            if (call.method != "recognizeText" && call.method != "pdfText") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            worker.execute {
                try {
                    val text = if (call.method == "pdfText") pdfText(path) else imageText(path)
                    main.post { result.success(text) }
                } catch (e: Exception) {
                    main.post { result.error("vision", e.message ?: "Could not read that file.", null) }
                }
            }
        }
    }

    private fun imageText(path: String): String {
        val bitmap = BitmapFactory.decodeFile(path) ?: throw IllegalArgumentException("Could not open that image.")
        return recognize(bitmap, rotation(path))
    }

    /** Renders the first pages and reads them, so typed and scanned PDFs both work. */
    private fun pdfText(path: String): String {
        val fd = ParcelFileDescriptor.open(File(path), ParcelFileDescriptor.MODE_READ_ONLY)
        PdfRenderer(fd).use { doc ->
            val pages = mutableListOf<String>()
            for (i in 0 until minOf(doc.pageCount, 10)) {
                doc.openPage(i).use { page ->
                    val scale = 2000f / max(page.width, page.height)
                    val bitmap = Bitmap.createBitmap(
                        (page.width * scale).toInt(), (page.height * scale).toInt(), Bitmap.Config.ARGB_8888,
                    )
                    bitmap.eraseColor(Color.WHITE)
                    page.render(bitmap, null, Matrix().apply { setScale(scale, scale) }, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    pages.add(recognize(bitmap, 0))
                    bitmap.recycle()
                }
            }
            return pages.filter { it.isNotBlank() }.joinToString("\n\n")
        }
    }

    /** Reads top to bottom, then left to right, joining fragments on the same line (as on iOS). */
    private fun recognize(bitmap: Bitmap, rotation: Int): String {
        val text = Tasks.await(recognizer.process(InputImage.fromBitmap(bitmap, rotation)))
        val height = if (rotation % 180 == 0) bitmap.height else bitmap.width
        val tolerance = height * 0.012f
        val items = text.textBlocks.flatMap { it.lines }.mapNotNull { line ->
            val box = line.boundingBox ?: return@mapNotNull null
            Triple(box.exactCenterY(), box.left, line.text)
        }
        val sorted = items.sortedWith { a, b ->
            if (abs(a.first - b.first) > tolerance) a.first.compareTo(b.first) else a.second.compareTo(b.second)
        }
        val lines = mutableListOf<Pair<Float, MutableList<String>>>()
        for ((y, _, t) in sorted) {
            val last = lines.lastOrNull()
            if (last != null && abs(last.first - y) < tolerance) last.second.add(t) else lines.add(y to mutableListOf(t))
        }
        return lines.joinToString("\n") { it.second.joinToString(" ") }
    }

    private fun rotation(path: String): Int = try {
        when (ExifInterface(path).getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90
            ExifInterface.ORIENTATION_ROTATE_180 -> 180
            ExifInterface.ORIENTATION_ROTATE_270 -> 270
            else -> 0
        }
    } catch (e: Exception) {
        0
    }
}
