import Flutter
import UIKit

public class SwiftFlutterVideoThumbnailPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_video_thumbnail", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterVideoThumbnailPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
