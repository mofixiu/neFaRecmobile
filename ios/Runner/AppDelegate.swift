import ActivityKit
import AVFoundation
import Flutter
import PDFKit
import UIKit
import UserNotifications
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets the timer's target alert show while the app is open.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NefaVision") {
      NefaVision.register(messenger: registrar.messenger())
    }
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NefaLive") {
      NefaLive.register(messenger: registrar.messenger())
    }
  }
}

/// On-device text and body-pose recognition for neFaRec. Nothing is uploaded.
final class NefaVision {
  private static var channel: FlutterMethodChannel?

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "nefarec/vision", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      let args = call.arguments as? [String: Any] ?? [:]
      guard let path = args["path"] as? String else {
        result(FlutterError(code: "args", message: "Missing file path.", details: nil))
        return
      }
      let url = URL(fileURLWithPath: path)
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let value: Any
          switch call.method {
          case "recognizeText": value = try recognizeText(url: url)
          case "pdfText": value = try pdfText(url: url)
          case "bodyPose": value = try bodyPose(url: url, fps: args["fps"] as? Double ?? 10)
          default:
            DispatchQueue.main.async { result(FlutterMethodNotImplemented) }
            return
          }
          DispatchQueue.main.async { result(value) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "vision", message: error.localizedDescription, details: nil))
          }
        }
      }
    }
    self.channel = channel
  }

  private struct Failure: LocalizedError {
    let errorDescription: String?
    init(_ message: String) { errorDescription = message }
  }

  // MARK: Text

  static func recognizeText(url: URL) throws -> String {
    guard let image = UIImage(contentsOfFile: url.path), let cg = image.cgImage else {
      throw Failure("Could not open that image.")
    }
    return try recognizeText(cgImage: cg, orientation: orientation(of: image))
  }

  static func recognizeText(
    cgImage: CGImage, orientation: CGImagePropertyOrientation = .up
  ) throws -> String {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    try VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
      .perform([request])
    let items: [(CGRect, String)] = (request.results ?? []).compactMap { obs in
      guard let text = obs.topCandidates(1).first?.string else { return nil }
      return (obs.boundingBox, text)
    }
    // Vision's origin is bottom-left: read top to bottom, then left to right,
    // joining fragments that sit on the same line.
    let sorted = items.sorted { a, b in
      abs(a.0.midY - b.0.midY) > 0.012 ? a.0.midY > b.0.midY : a.0.minX < b.0.minX
    }
    var lines: [(CGFloat, [String])] = []
    for (box, text) in sorted {
      if let last = lines.last, abs(last.0 - box.midY) < 0.012 {
        lines[lines.count - 1].1.append(text)
      } else {
        lines.append((box.midY, [text]))
      }
    }
    return lines.map { $0.1.joined(separator: " ") }.joined(separator: "\n")
  }

  static func pdfText(url: URL) throws -> String {
    guard let doc = PDFDocument(url: url) else { throw Failure("Could not open that PDF.") }
    let embedded = doc.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    if !embedded.isEmpty { return embedded }
    // A scanned PDF: read the first pages as images.
    var pages: [String] = []
    for i in 0..<min(doc.pageCount, 10) {
      guard let page = doc.page(at: i) else { continue }
      let bounds = page.bounds(for: .mediaBox)
      let scale = 2000 / max(bounds.width, bounds.height)
      let thumb = page.thumbnail(
        of: CGSize(width: bounds.width * scale, height: bounds.height * scale), for: .mediaBox)
      if let cg = thumb.cgImage { pages.append(try recognizeText(cgImage: cg)) }
    }
    return pages.joined(separator: "\n\n")
  }

  // MARK: Pose

  private static let joints: [(VNHumanBodyPoseObservation.JointName, String)] = [
    (.leftShoulder, "leftShoulder"), (.rightShoulder, "rightShoulder"),
    (.leftHip, "leftHip"), (.rightHip, "rightHip"),
    (.leftKnee, "leftKnee"), (.rightKnee, "rightKnee"),
    (.leftAnkle, "leftAnkle"), (.rightAnkle, "rightAnkle"),
    (.leftElbow, "leftElbow"), (.rightElbow, "rightElbow"),
    (.leftWrist, "leftWrist"), (.rightWrist, "rightWrist"),
    (.neck, "neck"), (.root, "root"),
  ]

  static func bodyPose(url: URL, fps: Double) throws -> [String: Any] {
    let asset = AVURLAsset(url: url)
    guard let track = asset.tracks(withMediaType: .video).first else {
      throw Failure("That file has no video.")
    }
    let size = track.naturalSize.applying(track.preferredTransform)
    let duration = CMTimeGetSeconds(asset.duration)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter = .zero
    generator.maximumSize = CGSize(width: 720, height: 720)

    var frames: [[String: Any]] = []
    let step = 1 / max(1, min(fps, 30))
    var t = 0.0
    while t < duration && frames.count < 900 {
      let cg = try generator.copyCGImage(
        at: CMTime(seconds: t, preferredTimescale: 600), actualTime: nil)
      let request = VNDetectHumanBodyPoseRequest()
      try VNImageRequestHandler(cgImage: cg, options: [:]).perform([request])
      var points: [String: [Double]] = [:]
      // The person nearest the camera is usually the largest detection.
      if let body = (request.results ?? []).max(by: { spread($0) < spread($1) }) {
        let found = try body.recognizedPoints(.all)
        for (name, key) in joints {
          if let p = found[name], p.confidence > 0 {
            points[key] = [Double(p.location.x), Double(1 - p.location.y), Double(p.confidence)]
          }
        }
      }
      frames.append(["t": t, "joints": points])
      t += step
    }
    return [
      "width": Double(abs(size.width)), "height": Double(abs(size.height)),
      "duration": duration, "frames": frames,
    ]
  }

  private static func spread(_ o: VNHumanBodyPoseObservation) -> CGFloat {
    guard let pts = try? o.recognizedPoints(.all).values.filter({ $0.confidence > 0.2 }),
      !pts.isEmpty
    else { return 0 }
    let xs = pts.map(\.location.x), ys = pts.map(\.location.y)
    return (xs.max()! - xs.min()!) * (ys.max()! - ys.min()!)
  }

  private static func orientation(of image: UIImage) -> CGImagePropertyOrientation {
    switch image.imageOrientation {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    case .upMirrored: return .upMirrored
    case .downMirrored: return .downMirrored
    case .leftMirrored: return .leftMirrored
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
  }
}

/// Shows the running timer on the lock screen and in the Dynamic Island.
final class NefaLive {
  private static var channel: FlutterMethodChannel?

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "nefarec/live", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard #available(iOS 16.2, *) else {
        result(false)
        return
      }
      let args = call.arguments as? [String: Any] ?? [:]
      switch call.method {
      case "supported":
        result(ActivityAuthorizationInfo().areActivitiesEnabled)
      case "show":
        show(args, result: result)
      case "end":
        Task {
          for activity in Activity<RestTimerAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
          }
          result(true)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }

  @available(iOS 16.2, *)
  private static func show(_ args: [String: Any], result: @escaping FlutterResult) {
    func date(_ key: String) -> Date {
      Date(timeIntervalSince1970: (args[key] as? Double ?? 0) / 1000)
    }
    let state = RestTimerAttributes.ContentState(
      label: args["label"] as? String ?? "Timer",
      kind: args["kind"] as? String ?? "rest",
      startedAt: date("startedAt"),
      targetAt: date("targetAt"),
      targetSeconds: args["targetSeconds"] as? Double ?? 0,
      pausedElapsed: args["pausedElapsed"] as? Double
    )
    let content = ActivityContent(state: state, staleDate: nil)
    Task {
      // One timer at a time: update it if it exists, otherwise start one.
      if let current = Activity<RestTimerAttributes>.activities.first {
        await current.update(content)
        result(true)
        return
      }
      do {
        _ = try Activity.request(
          attributes: RestTimerAttributes(workout: args["workout"] as? String ?? "neFaRec"),
          content: content,
          pushType: nil
        )
        result(true)
      } catch {
        result(FlutterError(code: "live", message: error.localizedDescription, details: nil))
      }
    }
  }
}
