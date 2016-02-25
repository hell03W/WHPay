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

#import "WHPay/WHPay.h"

#define kWindowWidth [[UIScreen mainScreen] bounds].size.width

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, strong) WXPayModel *wxPayModel;

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
    
    [WHPay alipayWithOrder:^(AlipayOrder *order) {
//**********************************************************************************************
        order.tradeNO = [WHPayUtil generateTradeNO]; //订单ID（由商家自行制定）***********
        order.productName = @"买东西"; //商品标题 ***********
        order.productDescription = @"测试支付宝支付, 测试支付宝支付"; //商品描述 *******
        order.amount = [NSString stringWithFormat:@"%.2f",money]; //商品价格 ********
        
        ////////////////////////////////////////////////
        // 下面四个属性, 默认是从宏定义中读取的, 如果需要是从服务器中获取的, 可以在这里赋值.
//        order.partner = @"";
//        order.seller = @"";
//        order.notifyURL = @""; //回调URL
//        order.privateKey = @"";
        
    } andCallBack:^(WHPayCode payCode) {
        NSLog(@"alipay call back . payCode = %ld", payCode);
    }];
}
// 微信支付付钱的过程
// 1. 向自己的服务器请求签名等信息
- (void)weixinPayMoney:(float)price
{

    NSDictionary *dic = @{@"orderCode" : @"2016000746",
                          @"amount" : [NSString stringWithFormat:@"%f",price],
                          @"userIP" : [WHPayUtil getIPAddress:YES]};
    [AFNTool requestWithUrlString:@"bee-rest/service/jaxrs/weixin/unify" params:dic success:^(NSDictionary *success) {
        NSLog(@"%@",success);
        if ([success[@"code"] isEqualToString:@"000"]) {
            _wxPayModel = [AssignToObject customObject:@"WxPayModel" fromDictionary:success[@"data"]];
            [self callWeChatPay:_wxPayModel];
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
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
// 2. 调起微信客户端
- (void)callWeChatPay:(WXPayModel *)wxPayModel
{
    // 调起微信支付
    [WHPay wechatWithRequest:^(PayReq *request) {
//**********************************************************************************************
        // 以下信息是微信支付必须的, 并且需要从服务器获取的
        request.partnerId = wxPayModel.partnerid; // 商户ID,从服务器获取 ************
        request.prepayId = wxPayModel.prepayid; // 预支付ID,服务器从微信服务器申请得到的 **************
        request.nonceStr = wxPayModel.noncestr; // *********
        request.timeStamp = [wxPayModel.timestamp intValue]; // 时间戳, 从服务器获取 **********
        request.sign = [WHPayUtil genSignWithPayReq:request appid:wxPayModel.appid]; // sign签名, 服务器获取 ******
        
    } andCallBack:^(WHPayCode payCode) {
        NSLog(@"WeChat call back . payCode = %ld", payCode);
    }];
        
}
// 苹果支付 去付钱
- (void)applePayMoney:(float)price
{

}

@end
