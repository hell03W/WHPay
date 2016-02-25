//
//  WHPay.h
//  WHPay
//
//  Created by Walden on 16/2/25.
//  Copyright © 2016年 Walden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WHPayPublicDefine.h"

typedef enum : NSUInteger {
    WHPayCodeSuccess,
    WHPayCodeFailure,
    WHPayCodeCancle,
} WHPayCode;

typedef void (^AlipayOrderBlock)(AlipayOrder *order);
typedef void (^WeChatRequestBlock)(PayReq *request);
typedef void (^PayCallBack)(WHPayCode payCode);

@interface WHPay : NSObject

// 支付宝支付处理
+ (void)alipayWithOrder:(AlipayOrderBlock)order andCallBack:(PayCallBack)payCode;

// 微信支付处理
+ (void)wechatWithRequest:(WeChatRequestBlock)request andCallBack:(PayCallBack)payCode;

@end
