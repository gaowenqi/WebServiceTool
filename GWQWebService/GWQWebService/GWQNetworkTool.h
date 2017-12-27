//
//  GWQNetworkTool.h
//  GWQWebService
//
//  Created by 高文奇 on 2017/12/27.
//  Copyright © 2017年 andy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void (^SuccessBlock) (id returnValue);
typedef void (^ErrorBlock) (NSString *msg);

@interface GWQNetworkTool : NSObject

/**
 *  数据的基本请求方式
 *
 *  @param headerDic        dataTypeCode
 *  @param bodyDic          请求参数
 *  @param apiName          接口名
 *  @param returnBlock      成功返回块
 *  @param errorBlock       失败返回块
 */
+(void)getServiceData:(NSDictionary*)headerDic
   withBodyDictionary:(NSDictionary*)bodyDic
             withApiName:(NSString*)apiName
      withReturnBlock:(SuccessBlock) returnBlock
       withErrorBlock:(ErrorBlock) errorBlock;




@end
