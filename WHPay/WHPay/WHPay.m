//
//  WHPay.m
//  WHPay
//
//  Created by Walden on 16/2/25.
//  Copyright © 2016年 Walden. All rights reserved.
//

#import "WHPay.h"

extern NSString *WHPayCallBackWeChatNotifition;

@implementation WHPay

+ (void)alipayWithOrder:(AlipayOrderBlock)orderBlock andCallBack:(PayCallBack)payCode
{
    AlipayOrder *order = [AlipayOrder order];

    orderBlock(order);
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    
    //partner和seller获取失败,提示
    if ([order.partner length] == 0 || [order.seller length] == 0 || [order.privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(order.privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:APPScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"同步请求结果   resultDic = %@", resultDic);
            int code = [[resultDic objectForKey:@"resultStatus"] intValue];
            WHPayCode pCode;
            if (code == 9000) {
                pCode = WHPayCodeSuccess;
            }
            else if (code == 6001){
                pCode = WHPayCodeCancle;
            }
            else{
                pCode = WHPayCodeFailure;
            }
            
            payCode(pCode);
        }];
    }
}

/*
 //                9000	订单支付成功
 //                8000	正在处理中
 //                4000	订单支付失败
 //                6001	用户中途取消
 //                6002	网络连接出错*/




// 微信支付处理
+ (void)wechatWithRequest:(WeChatRequestBlock)requestBlock andCallBack:(PayCallBack)payCallBack
{
    // 给全局变量赋值, 全局变量用来设置通知的标识
    WHPayCallBackWeChatNotifition = @"WHPayCallBackWeChatNotifition";
    
    PayReq *request = [[PayReq alloc] init];
    requestBlock(request);
    request.package = @"Sign=WXPay";
    [WXApi sendReq:request];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWeChatCallBack:) name:WHPayCallBackWeChatNotifition object:payCallBack];
}

- (void)getWeChatCallBack:(NSNotification *)noti
{
    // 执行一个block代码块 传一个参数即可
//    PayCallBack payCallBack = noti.object;
    WHPayCode pCode;
    
//    int code = noti
    
}

@end











