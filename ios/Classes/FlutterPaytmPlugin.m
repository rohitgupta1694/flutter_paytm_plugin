#import "FlutterPaytmPlugin.h"
#import <flutter_paytm_plugin/flutter_paytm_plugin-Swift.h>

@implementation FlutterPaytmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPaytmPlugin registerWithRegistrar:registrar];
}
@end
