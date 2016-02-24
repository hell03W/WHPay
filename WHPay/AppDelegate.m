//
//  AppDelegate.m
//  WHPay
//
//  Created by Walden on 16/2/22.
//  Copyright © 2016年 Walden. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //向微信注册，这句必需要有才能在具体的地方实现分享功能。
    //微信支付也需要 register 这个
    [WXApi registerApp:@"wxf6682ec08066f0eb" withDescription:@"小蜜蜂客户端"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
#pragma mark - 处理支付宝支付的回调
    //如果极简开发包不可用，会跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给开发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            NSLog(@"result = %@",resultDic);
        }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    // 微信支付
    if ([url.host isEqualToString:@"pay"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

/**
 *  处理来至QQ的响应
 *
 *  @param resp 响应体，根据响应结果作对应处理
 */
- (void)onResp:(id)resp
{
    NSString *message;
    
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        NSLog(@"response.errCoderesponse.errCoderesponse.errCode%d",response.errCode);
        
        switch (response.errCode) {
            case WXSuccess:{
                NSLog(@"successWXPay");
                NSNotification *notification = [NSNotification notificationWithName:@"orderPay" object:@"success"];
                [[NSNotificationCenter defaultCenter]postNotification:notification];
                break;
            }
            case WXErrCodeCommon:
                message = @"发送错误";
                break;
                
            case WXErrCodeUserCancel:
                message = @"支付已取消";
                break;
                
            case WXErrCodeSentFail:
                message = @"发送失败";
                break;
                
            case WXErrCodeUnsupport:
                message = @"微信不支持";
                break;
                //                WXErrCodeCommon     = -1,   /**< 普通错误类型    */
                //                WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
                //                WXErrCodeSentFail   = -3,   /**< 发送失败    */
                //                WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
                //                WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
            default:{
                NSLog(@"wxpay");
                break;
            }
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
