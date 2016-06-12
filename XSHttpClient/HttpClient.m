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
@property (nonatomic,copy) NSDictionary * mHeader;
@property (nonatomic,copy) NSDictionary * mFileDict;
@property (nonatomic,copy) NSSet *acceptFormat;
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

- (HttpClient *(^)(RequestType))setRequestType {
    return ^HttpClient *(RequestType type){
        self.mRequestType = type;
        return self;
    };
}

- (HttpClient *(^)(NSDictionary *))setFile {
    NSAssert(self.mRequestType == UPLOAD, @"GET POST 请求不支持上传文件,请使用UPLOAD");
    return ^HttpClient *(NSDictionary *fileDict){
        self.mFileDict = fileDict;
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

- (HttpClient *(^)(NSString *))appendAcceptFormat {
//    [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil]
    return ^HttpClient *(NSString *format){
        NSMutableSet *set = [NSMutableSet setWithSet:self.acceptFormat];
        [set addObject:format];
        self.responseSerializer.acceptableContentTypes = set;
        return self;
    };
}

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
    
    NSAssert(self.mUrl, @"未设置请求URL");
    
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
    
    //完成回调
    void (^completeOperate)(id  _Nonnull responseObject) = ^(id  _Nonnull responseObject){
        if (data) {
            data(responseObject);
        }
    };
    
    //失败回调
    void (^errorOperate)(NSError * _Nonnull error) = ^(NSError * _Nonnull error){
        NSLog(@"%@",error);
        if (failure) {
            failure();
        }
    };
    
    
    switch (self.mRequestType) {
        case GET:{
            [client GET:self.mUrl parameters:self.mParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                completeOperate(responseObject);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                errorOperate(error);
            }];
        }
            break;
        case POST:{
            [client POST:self.mUrl parameters:self.mParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                completeOperate(responseObject);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                errorOperate(error);
            }];
        }
            break;
        case UPLOAD:{
            [client POST:self.mUrl parameters:self.mParameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                NSAssert(self.mFileDict[@"data"], @"未设置data：文件数据");
                NSAssert(self.mFileDict[@"name"], @"未设置name：name参数");
                NSAssert(self.mFileDict[@"fileName"], @"未设置fileName：文件名称");
                NSAssert(self.mFileDict[@"fileType"], @"未设置fileType：文件格式");
                [formData appendPartWithFileData:self.mFileDict[@"data"] name:self.mFileDict[@"name"] fileName:self.mFileDict[@"fileName"] mimeType:self.mFileDict[@"fileType"]];
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                completeOperate(responseObject);
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                errorOperate(error);
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
    self.acceptFormat = self.responseSerializer.acceptableContentTypes;
//    [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil]
    self.mRequestSerializer = requestHttp;
    self.mResponseSerializer = responseJson;
    self.mParameters = nil;
    self.mHeader = nil;
    self.isDebug = NO;
}

@end

HttpClient *XSHttp(RequestType type){
    return XSHttpClient.setRequestType(type);
}