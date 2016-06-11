//
//  HttpClient.m
//  NetworkManager
//
//  Created by xiaos on 16/4/26.
//  Copyright © 2016年 wzx. All rights reserved.
//

#import "HttpClient.h"

@interface HttpClient ()
@property (nonatomic,copy)NSString *mUrl;
@property (nonatomic,assign)RequestType mRequestType;
@property (nonatomic,assign)RequestSerializer mRequestSerializer;
@property (nonatomic,assign)ResponseSerializer mResponseSerializer;
@property (nonatomic,copy)id mParameters;
@property (nonatomic,copy)NSDictionary * mHeader;
@property (nonatomic,assign)BOOL isDebug;
@end

@implementation HttpClient

+ (void)setServerHost:(NSString *)serverHost debugHost:(NSString *)debugHost{
    ServerHost = serverHost;
    DebugHost = debugHost;
}

+ (HttpClient *)manager {
    static HttpClient *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpClient alloc] init];
        [manager update];
    });
    return manager;
}

- (HttpClient *)make {
    return self;
}

- (HttpClient *)and {
    return self;
}

- (HttpClient *(^)(NSString *))url {
    return ^HttpClient *(NSString *url){
        self.mUrl = url;
        return self;
    };
}

- (HttpClient *(^)(RequestType))$ {
    return ^HttpClient *(RequestType type){
        self.mRequestType = type;
        return self;
    };
}

//设置请求参数
- (HttpClient *(^)(id))params{
    return ^HttpClient *(id p){
        self.mParameters = p;
        return self;
    };
}

//设置请求头
- (HttpClient *(^)(NSDictionary *))setHttpHeader {
    return ^HttpClient *(NSDictionary *dict){
        self.mHeader = dict;
        return self;
    };
}

//设置请求解析方式
- (HttpClient *(^)(RequestSerializer))setRequestSerializer{
    return ^HttpClient *(RequestSerializer type){
        self.mRequestSerializer = type;
        return self;
    };
}

//设置响应解析方式
- (HttpClient *(^)(ResponseSerializer))setResponseSerializer{
    return ^HttpClient *(ResponseSerializer type){
        self.mResponseSerializer = type;
        return self;
    };
}

//- (HttpClient *(^)(NSString *))setAcceptFormat {
//    
//    return ^HttpClient *(NSString *format){
//        NSMutableSet *set = [NSMutableSet setWithSet:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil]];
//        [set addObject:format];
//        self.responseSerializer.acceptableContentTypes = set;
//        return self;
//    };
//}

- (NSString *)filterUrl{
    
    if ([self.mUrl hasPrefix:@"http://"] || [self.mUrl hasPrefix:@"https://"]) {
        return self.mUrl;
    }
    
    if (!DebugHost || !ServerHost) {
        NSLog(@"请设置主机地址");
        return @"";
    }
    
    NSString *host;
    if (self.isDebug) {//开启测试服务器
        host = DebugHost;
    }else {
        host = ServerHost;
    }
    
    return [NSString stringWithFormat:@"%@/%@",host,self.mUrl];
}

- (HttpClient *(^)(BOOL))DeBug {
    return ^HttpClient *(BOOL isDebug){
        self.isDebug = isDebug;
        return self;
    };
}

- (void)data:(void (^)(id))data failure:(void (^)())failure {
    HttpClient *client = [[self class] manager];
//    client.responseSerializer.acceptableContentTypes
    
    //设置请求
    [self setRequest:client];
    [self setHeader:client];
    //设置响应
    [self setResopnse:client];
    //设置url
    self.mUrl = [self filterUrl];
    NSLog(@"%s-%d-%@",__func__,__LINE__,self.mUrl);
    
    switch (self.mRequestType) {
        case GET:{
            [client GET:self.mUrl parameters:self.mParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                if (data) {
                    data(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                NSLog(@"%@",error);
                if (failure) {
                    failure();
                }
            }];
        }
            break;
        case POST:{
            [client POST:self.mUrl parameters:self.mParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                if (data) {
                    data(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                NSLog(@"%@",error);
                if (failure) {
                    failure();
                }
            }];
        }
            break;
    }
    
}

//请求设置
- (void)setRequest:(HttpClient *)client {
    
    switch (client.mRequestSerializer) {
        case requestHttp:
            client.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case requestJson:
            client.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            break;
    }
}

- (void)setHeader:(HttpClient *)client{
    if (!self.mHeader) return;
    [self.mHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [client.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

//响应设置
- (void)setResopnse:(HttpClient *)client {
    
    switch (client.mResponseSerializer) {
        case responseHttp:
            client.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case responseJson:
            client.responseSerializer = [AFJSONResponseSerializer serializer];
        default:
            break;
    }
}



//初始化默认参数
- (void)update {
    self.mUrl = nil;
    self.mRequestType = GET;
    self.mRequestSerializer = requestHttp;
    self.mResponseSerializer = responseJson;
    self.mParameters = nil;
    self.mHeader = nil;
    self.isDebug = NO;
}

@end
