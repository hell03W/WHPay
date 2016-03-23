//
//  WHPay.h
//  WHPay
//
//  Created by Walden on 16/2/24.
//  Copyright © 2016年 Walden. All rights reserved.
//

#ifndef WHPayPublicDefine_h
#define WHPayPublicDefine_h



#endif /* WHPay_h */


#import "WHPayUtil.h"

#pragma mark - 支付宝要导入的库
#import <AlipaySDK/AlipaySDK.h>
#import "AlipayOrder.h"
#import "DataSigner.h"




#pragma mark - 微信支付要导入的库
#import "WXApi.h"
#import "WxPayModel.h"





#warning mark - 测试支付宝和微信时候需要配置的信息
// 支付宝需要配置的信息
#define APPScheme @"whpay"
#define AlipayNotifyURL @""
/**
 *  支付宝私钥
 */
#define PRIVATE @""

/**
 *  支付宝商户ID
 */
#define PARTNER @""
/**
 *  支付宝收款账号
 */
#define SELLER @""


/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 (这个是在 微信商户平台生成的)
 (已经是生成的了)  /Users/walden/Desktop/MyIOS/GithubProject/WHPay/WHPay/WHPay/WHPay.h:30:9:
 */
#define WXPartnerKey @""








#pragma mark - 全局变量, 通知类型

extern NSString *WHPayCallBackWeChatNotifition; // 微信回调的通知
extern NSString *WHPayCallBackAlipayNotifition; // 支付宝回调通知







