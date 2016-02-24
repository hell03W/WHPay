//
//  AFNTool.h
//  LittleBee
//
//  Created by  www.6dao.cc on 15/12/28.
//  Copyright © 2015年 www.6dao.com. All rights reserved.
//

/**
 默认是post请求
 */

#import "AFNetworking.h"

typedef enum {
    AFNToolRequestStyleGET,
    AFNToolRequestStylePOST,
} AFNToolRequestStyle;

@interface AFNTool : AFHTTPRequestOperationManager

//单例对象
+ (AFNTool *)shareAFNTool;

// 设置网络请求方式
+ (void)requestStyle:(AFNToolRequestStyle)requestStyle;  //默认 POST

//设置baseUrlString
+ (void)baseUrlString:(NSString *)baseUrlString;

//设置超时时间
+ (void)setTimeoutInterval:(NSInteger)second;


#pragma - mark 类方法 请求网络数据
+ (void)requestWithUrlString:(NSString *)urlString
                      params:(NSDictionary *)paramsDict
                     success:(void (^)(NSDictionary *success))success
                     failure:(void (^)(NSError *error))error;


#pragma - mark 取消网络请求
+ (void)cancleRequest;

#pragma mark 上传文件
+ (void)uploadFileWithUrlString:(NSString *)urlString
                           file:(NSData *)fileData
                        fileKey:(NSString *)fileKey
                         params:(NSDictionary *)paramsDict
                        success:(void (^)(NSDictionary *success))success
                        failure:(void (^)(NSError *error))error;






#pragma mark - 网络请求按照添加任务的顺序执行
- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//1, 添加n个任务
+ (void)addRequestWithHTTPMethod:(NSString *)method
                       UrlString:(NSString *)urlString
                          params:(id)paramsDict
                         success:(void (^)(NSDictionary *success))success
                         failure:(void (^)(NSError *error))error;
/**
 2, 开始执行
 开始执行任务, 按照顺序执行任务
 如果一定要保证任务的执行顺序, 也可以使用 executeSync 方法,
 */
+ (void)executeOperationsInOrder;

/**
 3, n个任务, 分块执行, 类似GCD的group
 参数数量可变, 场景: 前3个请求完成之后执行中间2个, 然后最后的4个, 参数:  @"3", @"2", @"4", nil
 */
+ (void)executeOperationsWithDependency:(NSString *)groupNum, ... NS_REQUIRES_NIL_TERMINATION;

/**
 4, 同步执行任务   block块中的代码, 会放在当前的线程中执行.
 返回值可以用来判断是否请求成功.
 */
+ (id)executeSync;

@end




// model类
typedef void (^SuccessBlock)(NSDictionary *success);
typedef void (^ErrorBlock)(NSError *error);

@interface RequestOperationModel : NSObject

+ (id)requestModel;

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *paramsDict;
@property (nonatomic, strong) SuccessBlock success;
@property (nonatomic, strong) ErrorBlock error;

@end




