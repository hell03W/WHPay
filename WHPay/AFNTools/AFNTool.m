//
//  AFNTool.m
//  LittleBee
//
//  Created by  www.6dao.cc on 15/12/28.
//  Copyright © 2015年 www.6dao.com. All rights reserved.
//

#import "AFNTool.h"
#import "Reachability.h"
#import <stdarg.h>



static NSString *baseUrl = @"http://121.196.233.59:8080/"; // 设置baseUrl
static AFNToolRequestStyle requestStyle;
static NSMutableArray *operations;

@interface AFNTool ()

@end

@implementation AFNTool

//单例对象
+ (AFNTool *)shareAFNTool
{
    static AFNTool *afnTool;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afnTool = [AFNTool manager];
        afnTool.responseSerializer = [AFJSONResponseSerializer serializer];
        afnTool.requestSerializer = [AFJSONRequestSerializer serializer];
        afnTool.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
        afnTool.requestSerializer.timeoutInterval = 10;  // 请求超时时间  10s
        
        operations = [NSMutableArray array]; //存放操作的数组
    });
    
    requestStyle = AFNToolRequestStylePOST; // 设置请求方式是post
    
    return afnTool;
}

// 设置请求方式
+ (void)requestStyle:(AFNToolRequestStyle)requestStyleParam
{
    requestStyle = requestStyleParam;
}

//设置baseUrlString
+ (void)baseUrlString:(NSString *)baseUrlString
{
    baseUrl = baseUrlString;
}

//设置超时时间
+ (void)setTimeoutInterval:(NSInteger)second
{
    [AFNTool shareAFNTool].requestSerializer.timeoutInterval = second;
}

#pragma - mark 类方法 请求网络数据
+ (void)requestWithUrlString:(NSString *)urlString
                      params:(NSDictionary *)paramsDict
                     success:(void (^)(NSDictionary *success))success
                     failure:(void (^)(NSError *error))failure
{
//    判断网络是否可用
    if(![Reachability currentReachabilityStatus]) //网络不可用时候
    {
#pragma mark - ios8.4 检测不到网络
        return;
    }
    
    if (urlString) {
        urlString = [baseUrl stringByAppendingString:urlString];
    }
    
    if (!paramsDict) { // 防止字典为nil, 导致程序崩溃.
        paramsDict = [NSDictionary dictionary];
    }
    
    AFNTool *afnTool = [AFNTool shareAFNTool];
    
    //post请求
    if (requestStyle == AFNToolRequestStylePOST) {
        [afnTool postRequestWithUrlString:(NSString *)urlString
                                   params:(NSDictionary *)paramsDict
                                  success:(void (^)(NSDictionary *))success
                                  failure:(void (^)(NSError *))failure];
    }
    //get请求
    else if (requestStyle == AFNToolRequestStyleGET){
        [afnTool getRequestWithUrlString:(NSString *)urlString
                                  params:(NSDictionary *)paramsDict
                                 success:(void (^)(NSDictionary *))success
                                 failure:(void (^)(NSError *))failure];
    }
    
}


//post请求
- (void)postRequestWithUrlString:(NSString *)urlString
                          params:(NSDictionary *)paramsDict
                         success:(void (^)(NSDictionary *))success
                         failure:(void (^)(NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFNTool shareAFNTool];
    
    [manager POST:urlString parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"\nFailure:\n url: %@\n Params: %@ \n Error: %@", urlString, paramsDict, error);

         failure(error);
     }];
}
//get请求
- (void)getRequestWithUrlString:(NSString *)urlString
                         params:(NSDictionary *)paramsDict
                        success:(void (^)(NSDictionary *))success
                        failure:(void (^)(NSError *))failure
{
    AFHTTPRequestOperationManager *manager = [AFNTool shareAFNTool];
    
    [manager GET:urlString parameters:paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"\nSuccess:\n url: %@\n dict: %@", urlString, responseObject);
         
         success(responseObject);
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"\nFailure:\n url: %@\n Params: %@ \n Error: %@", urlString, paramsDict, error);

         failure(error);
     }];
}


#pragma - mark 取消网络请求
+ (void)cancleRequest
{
    AFNTool *afnTool = [self shareAFNTool];
    [afnTool.operationQueue cancelAllOperations];
}


#pragma - mark 上传文件
+ (void)uploadFileWithUrlString:(NSString *)urlString
                           file:(NSData *)fileData
                        fileKey:(NSString *)fileKey
                         params:(NSDictionary *)paramsDict
                        success:(void (^)(NSDictionary *success))success
                        failure:(void (^)(NSError *error))failure
{
    if (urlString) {
        urlString = [baseUrl stringByAppendingString:urlString];
    }
    
    AFHTTPRequestOperationManager *manager = [self shareAFNTool];
    
    [manager POST:urlString parameters:paramsDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        
        [formData appendPartWithFileData:fileData name:fileKey fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         success(responseObject);
         
         NSLog(@"Success: %@", responseObject);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         failure(error);
         
         NSLog(@"Params:%@ \n.......\n Error: %@", paramsDict, error);
     }];
}




#pragma mark - 网络请求按照添加任务的顺序执行
//1, 添加n个任务
+ (void)addRequestWithHTTPMethod:(NSString *)method
                       UrlString:(NSString *)urlString
                     params:(id)paramsDict
                    success:(void (^)(NSDictionary *success))success
                    failure:(void (^)(NSError *error))failure
{
    [AFNTool shareAFNTool];
    RequestOperationModel *model = [RequestOperationModel requestModel];
    model.method = method;
    model.urlString = urlString;
    model.paramsDict = paramsDict;
    model.success = success;
    model.error = failure;
    [operations addObject:model];
}

//2, 开始执行, 任务按照添加顺序依次执行
+ (void)executeOperationsInOrder
{
    [self createOperations];
    AFNTool *afnTool = [AFNTool shareAFNTool];
    //给操作设置依赖关系
    for (int i = 0; i < operations.count - 1; i++) {
        NSOperation *op1 = [operations objectAtIndex:i];
        NSOperation *op2 = [operations objectAtIndex:i+1];
        [op2 addDependency:op1];
        
    }
    
    //添加操作
    [afnTool.operationQueue addOperations:operations waitUntilFinished:NO];
    
    [operations removeAllObjects];
}

//3, n个任务, 分块执行, 类似GCD的group
+ (void)executeOperationsWithDependency:(NSString *)groupNum, ... NS_REQUIRES_NIL_TERMINATION
{
    [self createOperations];
    AFNTool *afnTool = [AFNTool shareAFNTool];
    
    va_list varList;
    NSString *temp;
    
    if (groupNum == nil) {
        [afnTool.operationQueue addOperations:operations waitUntilFinished:NO];
        return;
    }
    
    NSMutableArray *paramArray = [NSMutableArray array];
    
    [paramArray addObject:groupNum];
    va_start(varList, groupNum);
    while ((temp = va_arg(varList, NSString *)) != nil)
    {
        [paramArray addObject:temp];
    }
    va_end(varList);
    
    // 检查传过来的字符串是否合法
    NSString * regex = @"^[0-9]\\d*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    for(NSString *item in paramArray)
    {
        if (![pred evaluateWithObject:item])
        {
            NSLog(@"分组数量必须为整数 !");
            return;
        }
    }
    
    // 防止阻塞主线程, 放到异步线程中操作
    dispatch_queue_t aQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(aQueue, ^{
        NSInteger location = 0;
        for(int i = 0; i < paramArray.count; i++)
        {
            NSInteger num = [[paramArray objectAtIndex:i] integerValue];
            
            if (num >= operations.count - location)
            {
                NSArray *ops = [operations subarrayWithRange:NSMakeRange(location, operations.count - location)];
                [afnTool.operationQueue addOperations:ops waitUntilFinished:YES];
                location += num;
                break;
            }
            
            NSArray *ops = [operations subarrayWithRange:NSMakeRange(location, num)];
            [afnTool.operationQueue addOperations:ops waitUntilFinished:YES];
            location += num;
        }
        
        if (operations.count > location)
        {
            NSArray *ops = [operations subarrayWithRange:NSMakeRange(location, operations.count - location)];
            [afnTool.operationQueue addOperations:ops waitUntilFinished:YES];
        }
        
        [operations removeAllObjects];
    });
}

//4, 同步执行任务
+ (id)executeSync
{
    NSMutableDictionary *responseDict = [NSMutableDictionary dictionary];
    
    AFNTool *afnTool = [AFNTool shareAFNTool];
    for (int i = 0; i < operations.count; i++)//RequestOperationModel *model in operations)
    {
        RequestOperationModel *model = [operations objectAtIndex:i];
        
        //1, 根据网络请求参数创建 自行创建 NSMutableURLResuest 对象
        NSString *urlString = [baseUrl stringByAppendingString:model.urlString];
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [afnTool.requestSerializer requestWithMethod:model.method URLString:[[NSURL URLWithString:urlString] absoluteString] parameters:model.paramsDict error:&serializationError];
        
        //2, 根据网络请求参数创建 自行创建 AFHTTPRequestOperation 对象
        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.responseSerializer = afnTool.responseSerializer;
        
        //3, 同步执行 AFHTTPRequestOperation
        [requestOperation start];
        [requestOperation waitUntilFinished];
        
        //4, 得到任务执行结果之后, 执行block代码块, 执行调用函数时候封装的操作
        if (requestOperation.responseObject) {
            model.success(requestOperation.responseObject);
            [responseDict setObject:requestOperation.responseObject forKey:[NSString stringWithFormat:@"%d", i]];
        }
        if (serializationError) {
            model.error(serializationError);
        }
    }
    
    [operations removeAllObjects];
    
    return responseDict;
}

// 将存在model中的请求数据 放到 AFHTTPRequestOperation 对象中去
+ (void)createOperations
{
    AFNTool *afnTool = [AFNTool shareAFNTool];
    NSArray *opModels = [NSArray arrayWithArray:operations];
    [operations removeAllObjects];
    
    for (RequestOperationModel *model in opModels)
    {
        NSString *urlString = [baseUrl stringByAppendingString:model.urlString];
        AFHTTPRequestOperation *op = [afnTool HTTPRequestOperationWithHTTPMethod:model.method URLString:urlString parameters:model.paramsDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            model.success(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            model.error(error);
        }];
        [operations addObject:op];
    }
}


@end







@implementation RequestOperationModel

+ (id)requestModel
{
    return [[self alloc] init];
}

@end


