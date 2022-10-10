
import 'flutter_video_thumbnail_platform_interface.dart';

class FlutterVideoThumbnail {
  Future<String?> getPlatformVersion() {
    return FlutterVideoThumbnailPlatform.instance.getPlatformVersion();
  }
}
