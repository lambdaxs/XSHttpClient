# XSHttpClient

链式语法的网络库
将分散的设置和操作聚合在一起。如下是对比AFN与链式调用的区别。

```objc
AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
//设置请求解析类型
[mgr setRequestSerializer:[AFHTTPRequestSerializer serializer]];
//设置响应解析类型
[mgr setResponseSerializer:[AFJSONResponseSerializer serializer]];
//设置响应可接收类型
mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//开始请求
[mgr POST:@"http://xxx" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
   NSLog(@"%@",responseObject);
} failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
   NSLog(@"%@",error);
}];
    
[XSHttp(GET)
.url(@"title/getall.json")
.params(nil)
.setRequestSerializer(requestHttp)
.setResponseSerializer(responseJson)
.appendAcceptFormat(@"text/html")
data:^(id responseObject) {
   NSLog(@"%@",responseObject);
} failure:^{
   NSLog(@"error");
}];
```

```objc
[XSHttp(GET)
.url(@"title/getall.json")
.params(param)
data:^(id responseObject) {
	NSLog(@"%@",responseObject);
} failure:^{
   NSLog(@"error");
}];
```

```objc
//开启测试 建议在appdelegate中设置
//[HttpClient setServerHost:@"https://www.xsdota.com/weibo/v1" debugHost:@"http://localhost:7888/weibo/v1"];
[XSHttp(POST)
.url(@"title/getall.json")
.params(param)
.DeBug(YES)
data:^(id responseObject) {
	NSLog(@"%@",responseObject);
} failure:^{
	NSLog(@"error");
}];
```

```objc
//添加设置请求解析 响应解析设置
[XSHttp(GET)
.url(@"title/getall.json")
.params(param)
.setRequestSerializer(requestHttp)
.setResponseSerializer(responseHttp)
data:^(id responseObject) {
   NSLog(@"%@",responseObject);
} failure:^{
   NSLog(@"error");
}];
```

```objc
//以from表单的形式上传图片
//setFile函数传字典 name：参数名，data：图片的二进制数据，fileName：文件名。fileType：文件格式
UIImage *image = [UIImage imageNamed:@"2"];
NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    
[XSHttp(UPLOAD)
.url(@"title/upload.json")
.setFile(@{@"name":@"image",
           @"data":imageData,
           @"fileName":@"xiaos1.jpg",
           @"fileType":@"image/jpg"})
.DeBug(YES)
data:^(id responseObject) {
   NSLog(@"%@",responseObject);
} failure:^{
   NSLog(@"error");
}];
```

