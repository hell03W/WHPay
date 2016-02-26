# WHPay
因为项目中多次用到支付宝和微信支付, 忙里偷闲, 对支付这个流程做了一个梳理, 对支付这个操作进行了一次封装. 支付流程以及处理请[点击这里](http://my.oschina.net/whforever/blog/620304).

**说明:**

	1. 当前项目中集成了微信支付和支付宝支付的封装, 后续会增加银联支付和ApplePay支付的操作和封装, 欢迎关注.
	2. 可以通过本项目测试注册的支付宝支付功能和微信支付功能是否成功, 可以用于测试.

## WHPay的简单使用
### 1, 将WHPay文件夹拖到工程中
#### 1.1 将包含各种支付方式相关库文件导入项目中, 在本项目中只需要导入WHPay文件夹即可.

#### 1.2 这时候会报出很多错误, 因为缺少一些依赖的类库. 导入以下相关的类库.
![](http://ww1.sinaimg.cn/large/6281e9fbgw1f1c18ypgedj20ba0dc40o.jpg)

#### 1.3 导入库后, 可能会出现找不到库文件的情况, 这时候需要修改库文件的搜索路径.
![](http://ww4.sinaimg.cn/large/6281e9fbgw1f1c19stkmij21kw0jnk1b.jpg)
一般情况下上述操作完成后, 程序是不会报出错误的, 这时候说明导入库第三方支付库已经成功, 下面可以开始做一些简单的项目配置工作, 就可以开发支付功能了 !

### 2, 配置工程
#### 2.1 在iOS9以后, 需要需要调起第三方应用, 需要在Info.plist中配置白名单.
如支付宝白名单:

```
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>alipay</string>
	</array>
```
#### 2.2 配置URLType, 用于支持应用间的跳转:
![](http://ww3.sinaimg.cn/large/6281e9fbgw1f1cmo0rf1qj21cm0gc0vo.jpg)

#### 2.3 在AppDeledate中导入头文件等
 在任何需要用到支付的地方, 导入 `#import "WHPay"`即可.

```
 #import "WHPay.h"

 extern NSString *WHPayCallBackWeChatNotifition;
```
微信需要在`- (BOOL)application: didFinishLaunchingWithOptions:`方法中向微信注册: 

```
// 微信支付 和 分享到微信都需要向应用注册
[WXApi registerApp:@"******" withDescription:@"*****"];
```
#### 2.4 微信和支付宝的回调:

这两个方法直接粘贴到APPDeledate中即可, 无序做任何修改.

```
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
    // 微信支付的回调, 发送一个收到回调的通知
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WHPayCallBackWeChatNotifition object:nil userInfo:@{@"errCode": [NSNumber numberWithInt:response.errCode]}];
    }
}
```

### 3, 在项目中调起微信或者支付宝
通过封装, 微信和支付宝的支付过程都在一个方法的两个block中完成, 第一个block需要补充请求支付时候必须的一些信息, 第二个block用来处理回调, 支付成功或者失败后会执行第二个block中的代码, 参数中包含了同步返回码信息, 但是支付状态一般都放在服务器中获取的, 从这里判断是不科学的.

#### 3.1 调起支付宝付钱的过程
```
// 支付宝付钱的过程
- (void)alipayPayMoney:(float)money
{
    NSLog(@"f支付宝支付 %.2f 元", money);
    
    [WHPay alipayWithOrder:^(AlipayOrder *order) {
//***********************************************************************************
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
```
#### 3.2 调起微信付钱的过程
```
// 2. 调起微信客户端
- (void)callWeChatPay:(WXPayModel *)wxPayModel
{
    // 调起微信支付
    [WHPay wechatWithRequest:^(PayReq *request) {
//***********************************************************************************
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
```





