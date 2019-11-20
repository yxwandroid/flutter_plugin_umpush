#import "FlutterPluginUmpushPlugin.h"
#import <flutter_plugin_umpush/flutter_plugin_umpush-Swift.h>

@implementation FlutterPluginUmpushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPluginUmpushPlugin registerWithRegistrar:registrar];
}
@end
