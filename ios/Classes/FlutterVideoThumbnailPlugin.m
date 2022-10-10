#import "FlutterVideoThumbnailPlugin.h"
#if __has_include(<flutter_video_thumbnail/flutter_video_thumbnail-Swift.h>)
#import <flutter_video_thumbnail/flutter_video_thumbnail-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_video_thumbnail-Swift.h"
#endif

@implementation FlutterVideoThumbnailPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVideoThumbnailPlugin registerWithRegistrar:registrar];
}
@end
