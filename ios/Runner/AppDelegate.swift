import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let audioEngine = LowLatencyAudioEngine()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "com.mgr.dsx_drum_kendang/audio",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(false)
        return
      }

      switch call.method {
      case "preload":
        guard let arguments = call.arguments as? [String: Any],
              let paths = arguments["paths"] as? [String] else {
          result(FlutterError(code: "INVALID_ARGS", message: "Paths are required", details: nil))
          return
        }
        self.audioEngine.preload(paths: paths) { result($0) }
      case "play":
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String,
              let volume = arguments["volume"] as? NSNumber else {
          result(FlutterError(code: "INVALID_ARGS", message: "Path and volume are required", details: nil))
          return
        }
        self.audioEngine.play(path: path, volume: volume.floatValue) { result($0) }
      case "release":
        self.audioEngine.release { result(true) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
