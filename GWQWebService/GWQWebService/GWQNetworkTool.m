//
//  GWQNetworkTool.m
//  GWQWebService
//
//  Created by 高文奇 on 2017/12/27.
//  Copyright © 2017年 andy. All rights reserved.
//

#import "GWQNetworkTool.h"

#warning 这里设置为你需要的地址
static NSString *const yourURL   = @"http://*******************";
static NSString *const basicSoap  = @"<?xml version=\"1.0\" encoding=\"utf-8\"?> \n"
"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
"<soap:Header>"
"<ValidationSoapHeader xmlns=\"http://liananet.com/\">";


@implementation GWQNetworkTool
+(AFHTTPSessionManager *)manager{
    static AFHTTPSessionManager *manager = nil;
    if (manager == nil) {
        manager = [AFHTTPSessionManager manager];
    }
    return manager;
}

+(void)getServiceData:(NSDictionary*)headerDic withBodyDictionary:(NSDictionary*)bodyDic withApiName:(NSString*)apiName withReturnBlock:(SuccessBlock) returnBlock withErrorBlock:(ErrorBlock) errorBlock{
    // 创建soap消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSMutableString *soapContent = [self GWQ_getSoapString:headerDic withBodyDic:bodyDic withApiName:apiName];
    //得到soap请求消息字符串长度
    NSString *soapLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapContent length]];
    AFHTTPSessionManager *mgr = [self manager];
    mgr.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    //设置加载时间
    mgr.requestSerializer.timeoutInterval = 20.0f;
    [mgr.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [mgr.requestSerializer setValue:soapLength forHTTPHeaderField:@"Content-Length"];
    // 根据上面的URL创建一个请求
    NSMutableURLRequest *request = [mgr.requestSerializer requestWithMethod:@"POST" URLString:yourURL parameters:nil error:nil];
    // 将SOAP消息加到请求中
    [request setHTTPBody:[soapContent dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask = [mgr dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError *  error)
                                       {
                                           if (responseObject) {
                                               NSDictionary * resultDic = [self GWQ_getResultdicWithData:responseObject withApiname:apiName];
                                            
                                               NSLog(@"resultDic == %@",resultDic);
                                               
                                           }else{
                                              
                                           }
                                           
                                       }];
    [dataTask resume];
}



#pragma mark ====请求数据之前的处理
/**得到Soap请求体*/
+(NSMutableString *)GWQ_getSoapString:(NSDictionary *)headerDic withBodyDic:(NSDictionary *)bodyDic withApiName:(NSString *)name{
    
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSMutableString *soapContent = [[NSMutableString alloc] initWithString:basicSoap];
    //组装头部信息
    id key, value;
    NSString *tempStr;
    NSArray *keys = [headerDic allKeys];
    NSInteger count = [keys count];
    for (int i = 0; i < count; i++){
        key = [keys objectAtIndex: i];
        value = [headerDic objectForKey: key];
        tempStr = [NSString stringWithFormat:@"<%@>%@</%@>",key,value,key];
        [soapContent appendString:tempStr];
    }
    //soap header
    [soapContent appendString:@"</ValidationSoapHeader>""</soap:Header>""<soap:Body>"];
    tempStr = [NSString stringWithFormat:@"<%@ xmlns=\"http://tempuri.org/\">",name];
    [soapContent appendString:tempStr];
    
    
    //组装body信息
    keys = [bodyDic allKeys];
    count = [keys count];
    for (int i = 0; i < count; i++){
        key = [keys objectAtIndex: i];
        value = [bodyDic objectForKey: key];
        tempStr = [NSString stringWithFormat:@"<%@>%@</%@>",key,value,key];
        [soapContent appendString:tempStr];
    }
    tempStr = [NSString stringWithFormat:@"</%@>",name];
    [soapContent appendString:tempStr];
    //得到soap请求消息
    [soapContent appendString:@"</soap:Body>"
     "</soap:Envelope>"];
    return soapContent;
}

#pragma mark ====得到数据之后的处理
/**根据返回的data得到字典*/
+(NSDictionary *)GWQ_getResultdicWithData:(NSData *)data withApiname:(NSString *)name{
    NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString * jsonString = [self getResultStr:dataString withApiName:name];
    NSData *responseData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    return jsonDic;
}

//得到网页响应示例中<BatchCarRepealResult>string</BatchCarRepealResult>中的string
+(NSString*)getResultStr:(NSString*)string withApiName:(NSString*)name {
    
    NSArray *array = [string componentsSeparatedByString:[NSString stringWithFormat:@"<%@Result>",name]];
    if (array.count < 2) {
        return nil;
    }
    NSArray *array2 = [[array objectAtIndex:1] componentsSeparatedByString:[NSString stringWithFormat:@"</%@Result>",name]];
    if (array.count < 1) {
        return nil;
    }
    NSString *resultStr = [array2 objectAtIndex:0];
    return resultStr;
}


@end
