//
//  ViewController.m
//  WHPay
//
//  Created by Walden on 16/2/22.
//  Copyright © 2016年 Walden. All rights reserved.
//

#import "ViewController.h"
#import "AFNTool.h"
#import "AssignToObject.h"

#pragma mark - 支付宝导入的库和宏定义

#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#import <CommonCrypto/CommonDigest.h>


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




#pragma mark - 微信支付的宏定义和导入的库

#import "WXApi.h"
#import "WxPayModel.h"

/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 (这个是在 微信商户平台生成的)
 (已经是生成的了)
 */
#define WXPartnerKey @"cAbXgB0gBcZlAYrNcRWDABnHmjvxohji"



#define kWindowWidth [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()

@property (nonatomic, strong) WxPayModel *wxPayModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configUI];
}

- (void)configUI
{
    // 支付宝支付按钮
    UIButton *alipay = [self getButtonWithTitle:@"支付宝支付"];
    [self.view addSubview:alipay];
    alipay.frame = CGRectMake(20, 50, kWindowWidth-40, 40);
    alipay.tag = 100;
    
    
    // 微信支付
    UIButton *wechatPay = [self getButtonWithTitle:@"微信支付"];
    [self.view addSubview:wechatPay];
    wechatPay.frame = CGRectMake(20, 100, kWindowWidth-40, 40);
    wechatPay.tag = 101;
    
    
    //苹果支付
    UIButton *applePay = [self getButtonWithTitle:@"苹果支付"];
    [self.view addSubview:applePay];
    applePay.frame = CGRectMake(20, 150, kWindowWidth-40, 40);
    applePay.tag = 102;
    
    
    //银联支付
    UIButton *unionPay = [self getButtonWithTitle:@"银联支付"];
    [self.view addSubview:unionPay];
    unionPay.frame = CGRectMake(20, 200, kWindowWidth-40, 40);
    unionPay.tag = 103;
}

- (UIButton *)getButtonWithTitle:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:0];
    [btn setTitleColor:[UIColor blackColor] forState:0];
    btn.layer.cornerRadius = 4;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:64];
    
    return btn;
}

- (void)btnClick:(UIButton *)sender
{
    NSLog(@"title = %@", [sender currentTitle]);
    if (sender.tag == 100) {
        // 支付宝支付
        [self alipayPayMoney:0.01];
    }
    else if (sender.tag == 101){
        // 微信支付
        [self weixinPayMoney:0.01];
    }
    else if (sender.tag == 102){
        // 苹果钱包
        [self applePayMoney:0.01];
    }
    else if (sender.tag == 103){
        // 银联支付
        [self applePayMoney:0.01];
    }
}

// 支付宝付钱的过程
- (void)alipayPayMoney:(float)money
{
    NSLog(@"f支付宝支付 %.2f 元", money);
    
    /*
     *点击获取prodcut实例并初始化订单信息
     */
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = PARTNER;
    NSString *seller = SELLER;
    NSString *privateKey = PRIVATE;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）***********
    order.productName = @"买东西"; //商品标题 ***********
    order.productDescription = @"测试支付宝支付, 测试支付宝支付"; //商品描述 *******
    order.amount = [NSString stringWithFormat:@"%.2f",money]; //商品价格 ********
    order.notifyURL = @"http://180.169.18.71/bee-web/notify_url.jsp"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types     
    NSString *appScheme = @"whpay";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    
    
}
// 微信支付付钱的过程
- (void)weixinPayMoney:(float)price
{

    NSDictionary *dic = @{@"orderCode" : @"2016000746",
                          @"amount" : [NSString stringWithFormat:@"%f",price],
                          @"userIP" : [ViewController getIPAddress:YES]};
    [AFNTool requestWithUrlString:@"bee-rest/service/jaxrs/weixin/unify" params:dic success:^(NSDictionary *success) {
        NSLog(@"%@",success);
        if ([success[@"code"] isEqualToString:@"000"]) {
            _wxPayModel = [AssignToObject customObject:@"WxPayModel" fromDictionary:success[@"data"]];
        }else{
            NSString *msg;
            if ([success[@"code"] isEqualToString:@"11780"]) {
                msg = @"获取预支付交易失败";
                return;
            }
            if ([success[@"code"] isEqualToString:@"11781"]) {
                msg = @"订单不存在";
                return;
            }
            if ([success[@"code"] isEqualToString:@"11782"]) {
                msg = @"缺参";
                return;
            }
            if ([success[@"code"] isEqualToString:@"11783"]) {
                msg = @"其他错误";
                return;
            }
        }
        if (_wxPayModel.prepayid) {
            // 调起微信支付
            PayReq *request = [[PayReq alloc]init];
            request.partnerId = _wxPayModel.partnerid;
            request.prepayId = _wxPayModel.prepayid;
            request.package = @"Sign=WXPay";
            request.nonceStr = _wxPayModel.noncestr;
            request.timeStamp = [_wxPayModel.timestamp intValue];
            
            // 这里要注意key里的值一定要填对， 微信官方给的参数名是错误的，不是第二个字母大写
            NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
            [signParams setObject: _wxPayModel.appid               forKey:@"appid"];
            [signParams setObject: _wxPayModel.partnerid           forKey:@"partnerid"];
            [signParams setObject: request.nonceStr      forKey:@"noncestr"];
            [signParams setObject: request.package       forKey:@"package"];
            [signParams setObject: _wxPayModel.timestamp forKey:@"timestamp"];
            [signParams setObject: request.prepayId      forKey:@"prepayid"];
            
            //生成签名
            NSString *sign  = [ViewController genSign:signParams];
            
            //添加签名
            request.sign = sign;
            
            [WXApi sendReq:request];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popToOrderVC) name:@"orderPay" object:nil];
        }else{

        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
// 苹果支付 去付钱
- (void)applePayMoney:(float)price
{

}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}




#pragma mark - 

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    
    // The dictionary keys have the form "interface" "/" "ipv4 or ipv6"
    return [addresses count] ? addresses : nil;
}

#pragma mark - 签名
/** 签名 */
+ (NSString *)genSign:(NSDictionary *)signParams
{
    // 排序, 因为微信规定 ---> 参数名ASCII码从小到大排序
    NSArray *keys = [signParams allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //生成 ---> 微信规定的签名格式
    NSMutableString *sign = [NSMutableString string];
    for (NSString *key in sortedKeys) {
        [sign appendString:key];
        [sign appendString:@"="];
        [sign appendString:[signParams objectForKey:key]];
        [sign appendString:@"&"];
    }
    NSString *signString = [[sign copy] substringWithRange:NSMakeRange(0, sign.length - 1)];
    
    // 拼接API密钥
    //    NSString *result = [NSString stringWithFormat:@"%@&key=%@", signString, WXPartnerKey];
    NSString *result = [NSString stringWithFormat:@"%@&key=%@",signString,WXPartnerKey];
    // 打印检查
    NSLog(@"result = %@", result);
    // md5加密
    NSString *signMD5 = [ViewController md5:result];
    // 微信规定签名英文大写
    signMD5 = signMD5.uppercaseString;
    // 打印检查
    NSLog(@"signMD5 = %@", signMD5);
    return signMD5;
}

+ (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
