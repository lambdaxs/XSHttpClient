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
