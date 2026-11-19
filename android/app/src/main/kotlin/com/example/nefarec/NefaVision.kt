package com.example.nefarec

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.Rect
import android.graphics.YuvImage
import android.graphics.pdf.PdfRenderer
import android.media.Image
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.ByteArrayOutputStream
import androidx.exifinterface.media.ExifInterface
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.pose.PoseDetection
import com.google.mlkit.vision.pose.PoseLandmark
import com.google.mlkit.vision.pose.accurate.AccuratePoseDetectorOptions
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

/**
 * On-device text recognition and body pose for neFaRec on Android, matching
 * the iOS `nefarec/vision` channel. ML Kit's bundled models, so nothing is
 * uploaded and it works offline.
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
            if (call.method !in setOf("recognizeText", "pdfText", "bodyPose")) {
                result.notImplemented()
                return@setMethodCallHandler
            }
            worker.execute {
                try {
                    val value: Any = when (call.method) {
                        "pdfText" -> pdfText(path)
                        "bodyPose" -> bodyPose(path, call.argument<Double>("fps") ?: 10.0)
                        else -> imageText(path)
                    }
                    main.post { result.success(value) }
                } catch (e: Exception) {
                    Log.e("NefaVision", "${call.method} failed", e)
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

    private val joints = listOf(
        PoseLandmark.LEFT_SHOULDER to "leftShoulder", PoseLandmark.RIGHT_SHOULDER to "rightShoulder",
        PoseLandmark.LEFT_HIP to "leftHip", PoseLandmark.RIGHT_HIP to "rightHip",
        PoseLandmark.LEFT_KNEE to "leftKnee", PoseLandmark.RIGHT_KNEE to "rightKnee",
        PoseLandmark.LEFT_ANKLE to "leftAnkle", PoseLandmark.RIGHT_ANKLE to "rightAnkle",
        PoseLandmark.LEFT_ELBOW to "leftElbow", PoseLandmark.RIGHT_ELBOW to "rightElbow",
        PoseLandmark.LEFT_WRIST to "leftWrist", PoseLandmark.RIGHT_WRIST to "rightWrist",
    )

    /**
     * Body landmarks sampled from a video, in the same shape as the iOS
     * channel: normalised 0–1 with a top-left origin, plus a confidence.
     * The video is decoded once, front to back, and sampled frames go to ML
     * Kit as NV21, so a clip with few keyframes doesn't get re-decoded per
     * sample. ML Kit has no neck or root point: those are the shoulder and
     * hip midpoints.
     */
    private fun bodyPose(path: String, fps: Double): Map<String, Any> {
        val meta = MediaMetadataRetriever()
        val rotation: Int
        val durationMs: Long
        try {
            meta.setDataSource(path)
            rotation = meta.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)?.toIntOrNull() ?: 0
            durationMs = meta.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0
        } finally {
            meta.release()
        }
        val extractor = MediaExtractor()
        extractor.setDataSource(path)
        val track = (0 until extractor.trackCount).firstOrNull {
            extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("video/") == true
        } ?: run {
            extractor.release()
            throw IllegalArgumentException("That file has no video.")
        }
        extractor.selectTrack(track)
        val format = extractor.getTrackFormat(track)
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible)
        val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
        val detector = PoseDetection.getClient(
            AccuratePoseDetectorOptions.Builder().setDetectorMode(AccuratePoseDetectorOptions.STREAM_MODE).build(),
        )
        val frames = mutableListOf<Map<String, Any>>()
        val raw = mutableListOf<Pair<Double, Map<String, List<Double>>>>()
        var width = 0
        var height = 0
        try {
            codec.configure(format, null, null, 0)
            codec.start()
            val step = 1.0 / fps.coerceIn(1.0, 30.0)
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            var outputDone = false
            var firstUs = -1L
            var nextT = 0.0
            while (!outputDone && frames.size < 900) {
                if (!inputDone) {
                    val i = codec.dequeueInputBuffer(10_000)
                    if (i >= 0) {
                        val n = extractor.readSampleData(codec.getInputBuffer(i)!!, 0)
                        if (n < 0) {
                            codec.queueInputBuffer(i, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(i, 0, n, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val o = codec.dequeueOutputBuffer(info, 10_000)
                if (o < 0) continue
                if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) outputDone = true
                if (info.size > 0) {
                    if (firstUs < 0) firstUs = info.presentationTimeUs
                    val t = (info.presentationTimeUs - firstUs) / 1_000_000.0
                    if (t + 0.001 >= nextT) {
                        codec.getOutputImage(o)?.let { image ->
                            try {
                                val (nv21, w, h) = nv21(image)
                                val upright = rotation == 90 || rotation == 270
                                width = if (upright) h else w
                                height = if (upright) w else h
                                val pose = detect(detector, nv21, w, h, rotation)
                                raw.add(t to joints(pose, width.toDouble(), height.toDouble()))
                            } finally {
                                image.close()
                            }
                        }
                        while (nextT <= t + 0.001) nextT += step
                    }
                }
                codec.releaseOutputBuffer(o, false)
            }
        } finally {
            runCatching { codec.stop() }
            codec.release()
            extractor.release()
            detector.close()
        }
        if (raw.isEmpty()) throw IllegalArgumentException("No frames could be read from that video.")
        // ML Kit's landmarks jitter more than Vision's: a light 3-frame average.
        for (i in raw.indices) {
            val smoothed = mutableMapOf<String, List<Double>>()
            for ((key, p) in raw[i].second) {
                val near = listOfNotNull(raw.getOrNull(i - 1)?.second?.get(key), p, raw.getOrNull(i + 1)?.second?.get(key))
                smoothed[key] = listOf(near.map { it[0] }.average(), near.map { it[1] }.average(), p[2])
            }
            frames.add(mapOf("t" to raw[i].first, "joints" to smoothed))
        }
        return mapOf(
            "width" to width.toDouble(), "height" to height.toDouble(),
            "duration" to durationMs / 1000.0, "frames" to frames,
        )
    }

    private var useBitmap = false

    /** NV21 straight to ML Kit; if this device's ML Kit rejects that, a bitmap instead. */
    private fun detect(
        detector: com.google.mlkit.vision.pose.PoseDetector, nv21: ByteArray, w: Int, h: Int, rotation: Int,
    ): com.google.mlkit.vision.pose.Pose {
        if (!useBitmap) {
            try {
                return Tasks.await(detector.process(InputImage.fromByteArray(nv21, w, h, rotation, InputImage.IMAGE_FORMAT_NV21)))
            } catch (e: Exception) {
                Log.w("NefaVision", "NV21 pose failed, using bitmaps", e)
                useBitmap = true
            }
        }
        val jpeg = ByteArrayOutputStream()
        YuvImage(nv21, ImageFormat.NV21, w, h, null).compressToJpeg(Rect(0, 0, w, h), 90, jpeg)
        val bytes = jpeg.toByteArray()
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        try {
            return Tasks.await(detector.process(InputImage.fromBitmap(bitmap, rotation)))
        } finally {
            bitmap.recycle()
        }
    }

    private fun joints(pose: com.google.mlkit.vision.pose.Pose, w: Double, h: Double): Map<String, List<Double>> {
        val points = mutableMapOf<String, List<Double>>()
        // ML Kit's likelihood says "in frame", not "visible". Use depth instead: the
        // leg further from the camera is partly hidden, so its points count for less.
        fun depth(types: List<Int>): Double {
            val zs = ArrayList<Double>()
            for (type in types) pose.getPoseLandmark(type)?.let { zs.add(it.position3D.z.toDouble()) }
            return if (zs.isEmpty()) Double.NaN else zs.average()
        }
        val leftZ = depth(listOf(PoseLandmark.LEFT_HIP, PoseLandmark.LEFT_KNEE, PoseLandmark.LEFT_ANKLE))
        val rightZ = depth(listOf(PoseLandmark.RIGHT_HIP, PoseLandmark.RIGHT_KNEE, PoseLandmark.RIGHT_ANKLE))
        val farSide: String? = when {
            leftZ.isNaN() || rightZ.isNaN() -> null
            leftZ > rightZ -> "left"
            else -> "right"
        }
        for ((type, key) in joints) {
            val lm = pose.getPoseLandmark(type) ?: continue
            if (lm.inFrameLikelihood <= 0f) continue
            val far = farSide != null && key.startsWith(farSide)
            val conf = lm.inFrameLikelihood.toDouble() * (if (far) 0.55 else 0.9)
            points[key] = listOf(lm.position.x / w, lm.position.y / h, conf)
        }
        fun mid(a: String, b: String, key: String) {
            val p = points[a] ?: return
            val q = points[b] ?: return
            points[key] = listOf((p[0] + q[0]) / 2, (p[1] + q[1]) / 2, min(p[2], q[2]))
        }
        mid("leftShoulder", "rightShoulder", "neck")
        mid("leftHip", "rightHip", "root")
        return points
    }

    /** YUV_420_888 decoder output to NV21, honouring the crop rectangle. */
    private fun nv21(image: Image): Triple<ByteArray, Int, Int> {
        val crop = image.cropRect
        // ML Kit's NV21 path needs the width to be a multiple of 4 (an 854-wide clip fails).
        val w = crop.width() and 3.inv()
        val h = crop.height() and 1.inv()
        val out = ByteArray(w * h * 3 / 2)
        val y = image.planes[0]
        val yBuf = y.buffer
        var pos = 0
        if (y.pixelStride == 1) {
            for (row in 0 until h) {
                yBuf.position((crop.top + row) * y.rowStride + crop.left)
                yBuf.get(out, pos, w)
                pos += w
            }
        } else {
            for (row in 0 until h) for (col in 0 until w) {
                out[pos++] = yBuf.get((crop.top + row) * y.rowStride + (crop.left + col) * y.pixelStride)
            }
        }
        val u = image.planes[1]
        val v = image.planes[2]
        val uBuf = u.buffer
        val vBuf = v.buffer
        for (row in 0 until h / 2) for (col in 0 until w / 2) {
            val cy = crop.top / 2 + row
            val cx = crop.left / 2 + col
            out[pos++] = vBuf.get(cy * v.rowStride + cx * v.pixelStride)
            out[pos++] = uBuf.get(cy * u.rowStride + cx * u.pixelStride)
        }
        return Triple(out, w, h)
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
