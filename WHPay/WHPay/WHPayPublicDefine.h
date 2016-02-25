//
//  WHPay.h
//  WHPay
//
//  Created by Walden on 16/2/24.
//  Copyright © 2016年 Walden. All rights reserved.
//

#ifndef WHPayPublicDefine_h
#define WHPayPublicDefine_h

/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 (这个是在 微信商户平台生成的)
 (已经是生成的了)  /Users/walden/Desktop/MyIOS/GithubProject/WHPay/WHPay/WHPay/WHPay.h:30:9:
 */
#define WXPartnerKey @"cAbXgB0gBcZlAYrNcRWDABnHmjvxohji"



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
#define AlipayNotifyURL @"http://180.169.18.71/bee-web/notify_url.jsp"
/**
 *  支付宝私钥
 */
#define PRIVATE @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBANpOE9U8lpDNp4L1dYaqTGy2uqSmGzORWhcFQI8TA6WEw78+kT/iOax+5N8qiA2Q6//l6o1mwScRzpYzh5rEQr/tf0eNa7fxCWWZwyFZYwSI5nXXWxwpJTyaYE7qe7xbJDDGDLkbPkLcHHbsMfpHfxR7OlCVWzRGCEHLKb0XrSsZAgMBAAECgYEAlyesr98t2cGsFQ9kewP7uuKjRVIGT6R7HqlyVB60Ta0p5IesBvHbQUbzrlpCrjIEVsGZsKLPZv/7bSDs6gqus/JuQZES7ZYE9HE1v0VTo6AJAvUJv/zoYQmv9LSh/pJpzsR38tbOQ3yGLS91H8vfAHsyGy4HW8u2gHl8FR8WRWkCQQD0Vsj0bcA0wHn9Z8ML7G7P9O73LdqUkKNfzlBGugPvr+FiZ+gpCsgzVyF4owbs2Su03rbH6CTVi4mClwfEUxh/AkEA5Lk4uczcQYuZrDVdUJ4JQDv9M0LEXoWDc8T925qHGXVowHnu9GI+2tukVTpa2PILg5qxdlSTGyEuCG/26xmwZwJABfFebeOFe0L7NJije9TCVTiF32k0GczyzE++UBoSInBKsRQJ54WlnOoPnFmKv5QApiOMmowg6Ti9nXmC7NmAjQJBAM/2KUGmps1h5MPTcZkPWFHzOXEWT/2xX6gvgLHfet8HBcucEkxZ19SeyHhFqrx+t0FdseVpWKfeL0C0rMlufhkCQQDIS5GX/Z/5IMSd7CBbn694ILLNotHHGkrK+dYOxd0pulPqVZmJR+ZsmbBm03rMr53A9nD1CrzwqJgDglZnloAn"

/**
 *  支付宝商户ID
 */
#define PARTNER @"2088121483945043"
/**
 *  支付宝收款账号
 */
#define SELLER @"services@chosenfm.cn"








#pragma mark - 全局变量, 通知类型

NSString *WHPayCallBackWeChatNotifition;







