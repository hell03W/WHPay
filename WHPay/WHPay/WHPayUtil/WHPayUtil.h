//
//  WHPayUtil.h
//  WHPay
//
//  Created by Walden on 16/2/24.
//  Copyright © 2016年 Walden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface WHPayUtil : NSObject

#pragma mark - 生成随机的订单号
+ (NSString *)generateTradeNO;

#pragma mark - sign签名, 在本地签名 (微信)
// 微信 在本地进行签名, 一般情况下签名是在服务端进行的, 这个签名方法可以用来测试
+ (NSString *)genSignWithPayReq:(PayReq *)request appid:(NSString *)appid;
+ (NSString *)genSign:(NSDictionary *)signParams;

#pragma mark - 获取本机的ip地址 (微信)
// 获取本地的ip地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
