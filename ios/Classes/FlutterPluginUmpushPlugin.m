#import "FlutterPluginUmpushPlugin.h"
#import <flutter_plugin_umpush/flutter_plugin_umpush-Swift.h>




//  oc 调用swift 的部分
//@implementation FlutterPluginUmpushPlugin
//+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
//  [SwiftFlutterPluginUmpushPlugin registerWithRegistrar:registrar];
//}
//@end


#import <UserNotifications/UserNotifications.h>
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
//#import <UMAnalytics/MobClick.h>
#import <UMCommonLog/UMCommonLogHeaders.h>

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

@interface FlutterPluginUmpushPlugin () <UNUserNotificationCenterDelegate>

@end

#endif

@implementation FlutterPluginUmpushPlugin {
    FlutterMethodChannel *_channel;
    NSDictionary *_launchNotification;
    BOOL _resumingFromBackground;
}
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    NSLog(@"umeng_push_plugin registerWithRegistrar registrar: %@", registrar);
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_plugin_umpush"
                                     binaryMessenger:[registrar messenger]];
    FlutterPluginUmpushPlugin *instance = [[FlutterPluginUmpushPlugin alloc] initWithChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar addApplicationDelegate:instance];
    NSLog(@"umeng_push_plugin register ok");
}
    
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        _resumingFromBackground = NO;
    }
    return self;
}
    
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"umeng_push_plugin handleMethodCall call: %@", call);
    NSString *method = call.method;
    if ([@"deviceToken" isEqualToString:method]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
//        if (_launchNotification != nil) {
//            [_channel invokeMethod:@"onLaunch" arguments:_launchNotification];
//        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *pushToken = [defaults objectForKey:@"pushToken"];
        NSString *deviceToken  = pushToken;
        if (deviceToken.length == 0) {
            return;
        }
        
        [_channel invokeMethod:@"deviceToken" arguments:deviceToken];
        result(nil);
    }else if([@"setAlias" isEqualToString:method]) {
      NSDictionary *args =  call.arguments;
      NSString *userName = [args valueForKey:@"alias"];
      [self setAliasWithUserName:userName];
     
      result(nil);
    }else {
        result(FlutterMethodNotImplemented);
    }
}
    
- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:nil error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
    
}
    
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"umeng_push_plugin didReceiveRemoteNotification userInfo: %@", userInfo);
    NSLog(@"umeng_push_plugin call onMessage: %@", _channel);
 //   [_channel invokeMethod:@"onMessage" arguments:[self convertToJsonData:userInfo]];
}
    
- (BOOL) application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"umeng_push_plugin application didFinishLaunchingWithOptions %@", _launchNotification);
    // Override point for customization after application launch.
    [UMCommonLogManager setUpUMCommonLogManager];
    [UMConfigure setLogEnabled:YES];
    
    
    [UMConfigure initWithAppkey:@"5dd658923fc1951fe000006a" channel:@"flutter"];
   // [MobClick event:@"flutter_ok"];
    NSLog(@"umeng_push_plugin application init umeng ok");
  
    
    // Push组件基本功能配置
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }else{
        }
    }];
    
    
//    UMessageRegisterEntity *entity = [[UMessageRegisterEntity alloc] init];
//    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
//    entity.types = UMessageAuthorizationOptionBadge | UMessageAuthorizationOptionAlert;
//#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//    if (@available(iOS 10.0, *)) {
//        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
//    } else {
//        // Fallback on earlier versions
//    }
//#endif
//    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError *_Nullable error) {
//        if (granted) {
//        } else {
//        }
//    }];
    _launchNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    return YES;
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    _resumingFromBackground = YES;
    NSLog(@"umeng_push_plugin applicationDidEnterBackground");
}
    
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    _resumingFromBackground = NO;
//    NSLog(@"umeng_push_plugin applicationDidBecomeActive");
//   // application.applicationIconBadgeNumber = 1;
//    application.applicationIconBadgeNumber = 1;
//}
//
//


    
//#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

    //iOS10新增：处理前台收到通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    NSLog(@"umeng_push_plugin userNotificationCenter willPresentNotification");
//    NSDictionary *userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [UMessage setAutoAlert:NO];
            //应用处于前台时的远程推送接受
            //必须加这句代码
            //[UMessage didReceiveRemoteNotification:userInfo];
            //        [self didReceiveRemoteNotification:userInfo];
        } else {
            //应用处于前台时的本地推送接受
        }
    } else {
        // Fallback on earlier versions
    }

}
    
    //iOS10新增：处理后台点击通知的代理方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSLog(@"umeng_push_plugin userNotificationCenter didReceiveNotificationResponse");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //应用处于后台时的远程推送接受
            //必须加这句代码
            //[UMessage didReceiveRemoteNotification:userInfo];
            [self didReceiveRemoteNotification:userInfo];
        } else {
            //应用处于后台时的本地推送接受
        }
    } else {
        // Fallback on earlier versions
    }
     [_channel invokeMethod:@"onMessage" arguments:[self convertToJsonData:userInfo]];
}
    
//#endif

- (NSString *)stringDevicetoken:(NSData *)deviceToken {
    NSString *token = [deviceToken description];
    NSString *pushToken = [[[token stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"umeng_push_plugin token: %@", pushToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:pushToken forKey:@"pushToken"];
    
 
    return pushToken;
}
    
    //  设置Tag
- (void)setAliasWithUserName:(NSString *)userName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [defaults objectForKey:@"pushToken"];
    NSString *deviceToken  = pushToken;
    if (deviceToken.length == 0 || userName.length == 0) {
        return;
    }
    NSString *uid = [deviceToken stringByAppendingString:userName];
    NSLog(@"UMessage setAlias:%@", uid);
    
    [_channel invokeMethod:@"onGetAlias" arguments:uid];
    
    [UIPasteboard generalPasteboard].string = uid;
    [UMessage setAlias:uid type:@"自有id" response:^(id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"UMessage setAlias responseObject:%@", responseObject);
        NSLog(@"UMessage setAlias error:%@", error.localizedDescription);
    }];
}
    
    
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"umeng_push_plugin application didReceiveRemoteNotification userInfo: %@", userInfo);
    
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    [self didReceiveRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoNotification" object:self userInfo:@{@"userinfo": [NSString stringWithFormat:@"%@", userInfo]}];
    
}
    
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"umeng_push_plugin application didRegisterForRemoteNotificationsWithDeviceToken%@", deviceToken);
    [self stringDevicetoken:deviceToken];
//    [_channel invokeMethod:@"onToken" arguments:[self stringDevicetoken:deviceToken]];
}
    
    
@end
