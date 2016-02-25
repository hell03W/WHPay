//
//  WxPayModel.h
//  newBee
//
//  Created by Get-CC on 16/1/26.
//  Copyright © 2016年 GET-CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXPayModel : NSObject

@property (nonatomic,strong)NSString *appid;
@property (nonatomic,strong)NSString *noncestr;
@property (nonatomic,strong)NSString *package;
@property (nonatomic,strong)NSString *partnerid;
@property (nonatomic,strong)NSString *prepayid;
@property (nonatomic,strong)NSString *sign;
@property (nonatomic,strong)NSString *timestamp;

@end
