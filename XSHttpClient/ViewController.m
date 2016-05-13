//
//  ViewController.m
//  XSHttpClient
//
//  Created by xiaos on 16/4/27.
//  Copyright © 2016年 com.xsdota. All rights reserved.
//

#import "ViewController.h"

#import "HttpClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //在appdelegate中设置
    [HttpClient setServerHost:@"https://www.xsdota.com/weibo/v1" debugHost:@"http://localhost:7888/weibo/v1"];
    
    NSDictionary *param = @{@"token":@"e0323a9039add2978bf5b49550572c7c"};
    
    [XSHttpClient
     .$(GET)
     .url(@"title/getall.json")
     .params(param)
     getSuccess:^(id responseObject) {
         NSLog(@"%@",responseObject);
    } failure:^{
        NSLog(@"error");
    }];
    
    
    //开启测试
    [XSHttpClient
     .$(POST)
     .url(@"title/getall.json")
     .params(param)
     .DeBug(YES)
     getSuccess:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^{
        NSLog(@"error");
    }];
    
    //添加设置请求解析 响应解析设置
    [XSHttpClient
     .$(GET)
     .url(@"title/getall.json")
     .params(param)
     .setRequestSerializer(requestHttp)
     .setResponseSerializer(responseHttp)
     getSuccess:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^{
        NSLog(@"error");
    }];
    
    //添加请求头key/value
    [XSHttpClient
     .$(GET)
     .url(@"title/getall.json")
     .params(param)
     .setHttpHeader(@{@"key1":@"value1"})
    getSuccess:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^{
        NSLog(@"error");
    }];
    
}



@end
