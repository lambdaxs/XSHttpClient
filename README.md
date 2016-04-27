# XSHttpClient
链式语法的网络库

```objc
[XSHttpClient.$(GET).url(@"title/getall.json").params(param)
getSuccess:^(id responseObject) {
	NSLog(@"%@",responseObject);
} failure:^{
   NSLog(@"error");
}];
```

```objc
//开启测试 建议在appdelegate中设置
//[HttpClient setServerHost:@"https://www.xsdota.com/weibo/v1" debugHost:@"http://localhost:7888/weibo/v1"];
[XSHttpClient.$(POST).url(@"title/getall.json").params(param).DeBug(YES)
getSuccess:^(id responseObject) {
	NSLog(@"%@",responseObject);
} failure:^{
	NSLog(@"error");
}];
```

```objc
//添加设置请求解析 响应解析设置
[XSHttpClient.$(GET).url(@"title/getall.json").params(param)
.setRequestSerializer(requestHttp)
.setResponseSerializer(responseHttp)
getSuccess:^(id responseObject) {
   NSLog(@"%@",responseObject);
} failure:^{
   NSLog(@"error");
}];
```


