import Darwin
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Retained so the channel's handler stays alive.
  private var clockChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ClockGuardChannel") {
      let channel = FlutterMethodChannel(
        name: "net.guilhermegomes.mytokens/clock",
        binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "monotonic":
          var ts = timespec()
          clock_gettime(CLOCK_MONOTONIC, &ts)
          result(Int64(ts.tv_sec) * 1000 + Int64(ts.tv_nsec / 1_000_000))
        case "networkTime":
          // No public iOS API for OS-synced network time.
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      clockChannel = channel
    }
  }
}
