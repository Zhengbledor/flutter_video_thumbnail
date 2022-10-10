import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_video_thumbnail_method_channel.dart';

abstract class FlutterVideoThumbnailPlatform extends PlatformInterface {
  /// Constructs a FlutterVideoThumbnailPlatform.
  FlutterVideoThumbnailPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterVideoThumbnailPlatform _instance = MethodChannelFlutterVideoThumbnail();

  /// The default instance of [FlutterVideoThumbnailPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterVideoThumbnail].
  static FlutterVideoThumbnailPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterVideoThumbnailPlatform] when
  /// they register themselves.
  static set instance(FlutterVideoThumbnailPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
