 //
//  ETAFNetworking.h
//  Ethome
//
//  Created by ethome on 16/8/3.
//  Copyright © 2016年 Whalefin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//判断网络状态枚举
typedef enum{
    ReachabilityStatusReachableViaWiFi,//WIFI
    ReachabilityStatusReachableViaWWAN,//自带网络
    ReachabilityStatusNotReachable,//没有网络
    ReachabilityStatusUnknown//未知网络
}ReachabilityStatus;


@interface ETAFNetworking : NSObject

/*
 //添加请求格式 一般错误会显示 “text/html”
 session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
 自己添加 请求头 使用 [session.requestSerializer setValue:Value forHTTPHeaderField:key];
 
 */
+ (AFSecurityPolicy *)customSecurityPolicyWithGW:(BOOL)isGw;

//get请求
+(void)getLMK_AFNHttpSrt:(NSString *)urlStr andTimeout:(float)time andParam:(NSDictionary *)dic success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure WithHud:(BOOL) isHave AndTitle:(NSString *)title;;

//post字典键值请求
+(AFHTTPSessionManager*)postLMK_AFNHttpSrt:(NSString *)urlStr parameters:(NSMutableDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure WithHud:(BOOL) isHave AndTitle:(NSString *)title;

//put请求
+(void)putLMK_AFNHttpSrt:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//delete请求
+(void)deleteLMK_AFNHttpSrt:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//判断网络状态
+ (void)setLMK_ReachabilityStatusChangeBlock:(void (^)(ReachabilityStatus status))block;

+ (NSMutableDictionary *)rulesOfParametersWithDictionary:(NSMutableDictionary *)parameters AndUrl:(NSString *)urlStr;

+(void)postLMK_AFNHttpSrt:(NSString *)urlStr parameters:(NSMutableDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+(void)getCSQ_AFNHttpSrt:(NSString *)urlStr andTimeout:(float)time andParam:(NSDictionary *)dic success:(void (^)(id responseObject))success failure:(void (^)(id error))failure WithHud:(BOOL)isHave AndTitle:(NSString *)title;

@end
