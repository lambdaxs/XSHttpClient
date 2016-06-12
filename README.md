# XSHttpClient
链式语法的网络库

```objc
[XSHttpClient
.$(GET)
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
[XSHttpClient
.$(POST)
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
[XSHttpClient
.$(GET)
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
    
[XSHttpClient
.$(UPLOAD)
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

