import 'dart:io';

import 'package:flutter/services.dart';

/// On-device text and body-pose recognition. Nothing leaves the phone.
/// Apple Vision on iOS, ML Kit on Android.
class VisionService {
  const VisionService();

  static const _channel = MethodChannel('nefarec/vision');

  /// Photo, screenshot and PDF text.
  bool get readsText => Platform.isIOS || Platform.isAndroid;

  /// Body pose for the squat form check.
  bool get readsPose => Platform.isIOS || Platform.isAndroid;

  /// Text in a photo or screenshot, line by line, top to bottom.
  Future<String> textFromImage(String path) async {
    final text = await _channel.invokeMethod<String>('recognizeText', {'path': path});
    return text ?? '';
  }

  /// Text in a PDF: embedded text when there is some, otherwise OCR of the
  /// first pages.
  Future<String> textFromPdf(String path) async {
    final text = await _channel.invokeMethod<String>('pdfText', {'path': path});
    return text ?? '';
  }

  /// Body landmarks in one live camera frame (BGRA on iOS, NV21 on Android),
  /// normalised to the upright frame. [rotation] turns the raw frame upright.
  Future<LivePose> poseFromFrame({
    required Uint8List bytes,
    required int width,
    required int height,
    required int bytesPerRow,
    int rotation = 0,
  }) async {
    final raw = await _channel.invokeMapMethod<String, Object?>('poseFrame', {
      'bytes': bytes,
      'width': width,
      'height': height,
      'bytesPerRow': bytesPerRow,
      'rotation': rotation,
    });
    return LivePose.fromMap(raw ?? const {});
  }

  /// Body landmarks sampled from a video at [fps].
  Future<PoseClip> poseFromVideo(String path, {double fps = 10}) async {
    final raw = await _channel.invokeMapMethod<String, Object?>('bodyPose', {
      'path': path,
      'fps': fps,
    });
    return PoseClip.fromMap(raw ?? const {});
  }
}

class Joint {
  const Joint(this.x, this.y, this.confidence);

  /// Normalised 0–1, origin top-left.
  final double x;
  final double y;
  final double confidence;
}

class PoseFrame {
  const PoseFrame(this.t, this.joints);

  /// Seconds from the start of the clip.
  final double t;
  final Map<String, Joint> joints;
}

class PoseClip {
  const PoseClip({required this.width, required this.height, required this.frames});

  factory PoseClip.fromMap(Map<String, Object?> m) {
    final frames = <PoseFrame>[];
    for (final f in (m['frames'] as List? ?? const [])) {
      final map = Map<String, Object?>.from(f as Map);
      final joints = <String, Joint>{};
      (map['joints'] as Map? ?? const {}).forEach((k, v) {
        final p = (v as List).cast<num>();
        joints[k as String] = Joint(p[0].toDouble(), p[1].toDouble(), p[2].toDouble());
      });
      frames.add(PoseFrame((map['t'] as num).toDouble(), joints));
    }
    return PoseClip(
      width: (m['width'] as num?)?.toDouble() ?? 1,
      height: (m['height'] as num?)?.toDouble() ?? 1,
      frames: frames,
    );
  }

  final double width;
  final double height;
  final List<PoseFrame> frames;
}

/// One live frame's landmarks and the upright frame size they are relative to.
class LivePose {
  const LivePose({required this.width, required this.height, required this.joints});

  factory LivePose.fromMap(Map<String, Object?> m) {
    final joints = <String, Joint>{};
    (m['joints'] as Map? ?? const {}).forEach((k, v) {
      final p = (v as List).cast<num>();
      joints[k as String] = Joint(p[0].toDouble(), p[1].toDouble(), p[2].toDouble());
    });
    return LivePose(
      width: (m['width'] as num?)?.toDouble() ?? 1,
      height: (m['height'] as num?)?.toDouble() ?? 1,
      joints: joints,
    );
  }

  final double width;
  final double height;
  final Map<String, Joint> joints;
}
