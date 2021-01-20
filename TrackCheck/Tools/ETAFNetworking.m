
//
//  ETAFNetworking.m
//  Ethome
//
//  Created by ethome on 16/8/3.
//  Copyright © 2016年 Whalefin. All rights reserved.
//

#import "ETAFNetworking.h"

@implementation ETAFNetworking

//+ (AFSecurityPolicy *)customSecurityPolicyWithGW:(BOOL)isGw
//{
//    //先导入证书，找到证书的路径
//    NSString *cerPath;
//    if (!isGw) {
//        if ([[ETAPIList getAPIList].rootUrl isEqualToString:LOCALSERVER_WANG]) {
//
//            cerPath = [[NSBundle mainBundle] pathForResource:@"localhost" ofType:@"cer"];
//
//        }else if ([[ETAPIList getAPIList].rootUrl isEqualToString:TESTSERVER]){
//
//            cerPath = [[NSBundle mainBundle] pathForResource:@"testethomecom" ofType:@"crt"];
//
//        }else{
//
//            cerPath = [[NSBundle mainBundle] pathForResource:@"yunethomecom" ofType:@"crt"];
//
//        }
//
//    }else{
//
//        cerPath = [[NSBundle mainBundle] pathForResource:@"gwserver" ofType:@"cer"];
//
//    }
//
//    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
//
//    //AFSSLPinningModeCertificate 使用证书验证模式
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//
//    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
//    //如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = YES;
//
//    //validatesDomainName 是否需要验证域名，默认为YES；
//
//    securityPolicy.validatesDomainName = NO;
//    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
//    securityPolicy.pinnedCertificates = set;
//
//    return securityPolicy;
//}


+(void)getLMK_AFNHttpSrt:(NSString *)urlStr andTimeout:(float)time andParam:(NSDictionary *)dic success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure WithHud:(BOOL)isHave AndTitle:(NSString *)title{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isHave) {
            
            if (title) {
                
                [HUD showUIBlockingIndicatorWithText:title];
            }else{
                
                [HUD showUIBlockingIndicator];
                
            }
            
        }
    });

    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.responseSerializer = [AFHTTPResponseSerializer serializer];

    session.requestSerializer.timeoutInterval = time;
    
//    [session setSecurityPolicy:[self customSecurityPolicyWithGW:YES]];
 
    [session GET:urlStr parameters:dic headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isHave) {
                [HUD hideUIBlockingIndicator];
            }
        });
        
        NSDictionary *responseObjectDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        NSLog(@"获取到的数据%@",responseObjectDic);
        
        
        NSMutableDictionary *response = [(NSDictionary *)responseObjectDic mutableCopy];
        
        if (![responseObjectDic[@"result"] boolValue]) {
            NSString *errorCode = responseObjectDic[@"errorCode"];
            
            NSString *errorMsg = [self getErrorMsgByErrorCode:errorCode];
            
            [response setValue:errorMsg forKey:@"errorMsg"];
            
        }
        
        success(response);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideUIBlockingIndicator];
        });
        failure(error);

    }];
    
}

+(AFHTTPSessionManager*)postLMK_AFNHttpSrt:(NSString *)urlStr parameters:(NSMutableDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure WithHud:(BOOL)isHave AndTitle:(NSString *)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isHave) {
            
            if (title) {
                
                [HUD showUIBlockingIndicatorWithText:title];
            }else{
                
                [HUD showUIBlockingIndicator];
                
            }
            
        }
    });
    
    NSLog(@"🐱调用了%@",urlStr);

    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    session.responseSerializer = [AFHTTPResponseSerializer serializer];
////    [session setSecurityPolicy:[self customSecurityPolicyWithGW:NO]];
//
//    if ([urlStr isEqualToString:[ETAPIList getAPIList].updateGW] || [urlStr isEqualToString:[ETAPIList getAPIList].addNvripc] || [urlStr isEqualToString:[ETAPIList getAPIList].delNvripc]) {
//
//        session.requestSerializer.timeoutInterval = 30.f;
//
//    }else if ([urlStr isEqualToString:[ETAPIList getAPIList].deviceUpdateAPI] || [ETAPIList getAPIList].addbgmusic){
//
//        session.requestSerializer.timeoutInterval = 15.f;
//
//    }else if ([urlStr isEqualToString:[ETAPIList getAPIList].changeWifiPwd] ){
//
//        session.requestSerializer.timeoutInterval = 300.f;
//
//    }
//    else{
//
//        session.requestSerializer.timeoutInterval = 8.f;
//
//    }
//    NSMutableDictionary *dic = [self rulesOfParametersWithDictionary:parameters AndUrl:urlStr];
//
//    NSLog(@"🐱参数为%@",dic);
//
//    [session POST:urlStr parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (isHave) {
//                [HUD hideUIBlockingIndicator];
//            }
//        });
//        NSDictionary *responseObjectDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//
//        NSLog(@"%@",responseObjectDic);
//
//        NSMutableDictionary *response = [(NSDictionary *)responseObjectDic mutableCopy];
//        if (![responseObjectDic[@"processResult"] boolValue]) {
//            NSString *errorMsg = responseObjectDic[@"errorMsg"];
//            if ([errorMsg integerValue] == QUANSHI_ERROR || [errorMsg integerValue] == THIRD_ERROR  || [errorMsg integerValue] == ChangeWiFi_Error) {
//
//                [response setValue:responseObjectDic[@"resultMap"][@"content"] forKey:@"errorMsg"];
//
//            }else{
//
//                errorMsg = [self getErrorMsgByErrorCode:errorMsg];
//
//                [response setValue:errorMsg forKey:@"errorMsg"];
//            }
//
//        }
//
//        success(response);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [HUD hideUIBlockingIndicator];
//
//            kFailureAlertView;
//
//            NSLog(@"🐱错误为%@",error);
//
//        });
//        failure(error);
//    }];
    return session;
}
//put请求

+(void)getCSQ_AFNHttpSrt:(NSString *)urlStr andTimeout:(float)time andParam:(NSDictionary *)dic success:(void (^)(id responseObject))success failure:(void (^)(id error))failure WithHud:(BOOL)isHave AndTitle:(NSString *)title{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isHave) {
            
            if (title) {
                
                [HUD showUIBlockingIndicatorWithText:title];
            }else{
                
                [HUD showUIBlockingIndicator];
                
            }
            
        }
    });
    
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//
//    session.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    session.requestSerializer.timeoutInterval = time;
//
////    [session setSecurityPolicy:[self customSecurityPolicyWithGW:YES]];
//    NSMutableDictionary *dict = [self rulesOfParametersWithDictionary:dic AndUrl:urlStr];
//
//    NSLog(@"🐱参数为%@",dict);
//    [session GET:urlStr parameters:dict headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (isHave) {
//                [HUD hideUIBlockingIndicator];
//            }
//        });
//        NSDictionary *responseObjectDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//
//        NSLog(@"%@",responseObjectDic);
//
//        NSMutableDictionary *response = [(NSDictionary *)responseObjectDic mutableCopy];
//        if ([responseObjectDic[@"processResult"] boolValue]) {
//
//            if ([urlStr containsString:@"lifesmt"] && ![urlStr containsString:@"spot/me"]) {
//
//                NSString *content = response[@"resultMap"][@"content"];
//
//                NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
//                NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
//
//                success(responseJSON[@"message"]);
//
//            }else{
//
//                success(response);
//
//            }
//
//        }else{
//
//            NSString *errorMsg = responseObjectDic[@"errorMsg"];
//
//            if ([errorMsg integerValue] == QUANSHI_ERROR || [errorMsg integerValue] == THIRD_ERROR || [errorMsg integerValue] == ChangeWiFi_Error || [errorMsg integerValue] == 4192) {
//
//                [response setValue:responseObjectDic[@"resultMap"][@"content"] forKey:@"errorMsg"];
//
//                errorMsg = responseObjectDic[@"resultMap"][@"content"];
//
//            }else{
//                errorMsg = [self getErrorMsgByErrorCode:errorMsg];
//
//                [response setValue:errorMsg forKey:@"errorMsg"];
//            }
//
//            id contentArr = responseObjectDic[@"resultMap"][@"content"];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([errorMsg isEqualToString:@"设备重复"] || [errorMsg isEqualToString:@"设备重复"]) {
//
//                    [HUD showAlertWithText:[NSString stringWithFormat:@"%@%@",[contentArr componentsJoinedByString:@"-"],errorMsg]];
//
//                }else if ([errorMsg isEqualToString:@"已存在与其它联动中"]){
//
//                    if ([contentArr count] == 3) {
//                        [HUD showAlertWithText:[NSString stringWithFormat:@"%@-%@已存在于(%@)的联动中",contentArr[1],contentArr[2],contentArr[0]]];
//                    }else{
//                        [HUD showAlertWithText:errorMsg];
//                    }
//
//                }else if ([errorMsg isEqualToString:@"设备不在线"]){
//
//                    if ([[contentArr class] isKindOfClass:[NSString class]]) {
//                        if ([contentArr length] > 0) {
//                            [HUD showAlertWithText:[NSString stringWithFormat:@"%@%@",contentArr,errorMsg]];
//                        }
//                    }else{
//                        [HUD showAlertWithText:errorMsg];
//                    }
//
//                }else if ([errorMsg isEqualToString:@"设备已被别人添加"]){
//                    [HUD showAlertWithText:[NSString stringWithFormat:@"设备已被%@添加",contentArr]];
//                }else if ([errorMsg isEqualToString:@"长期密码已无空缺index"]) {
//                    [HUD showAlertWithText:@"长期密码生成个数已达上限"];
//                }
//                else{
//                    if (![errorMsg isEqualToString:@"0000"]) {
//                        [HUD showAlertWithText:errorMsg];
//                    }
//                }
                
//                failure();
//
//            });
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"🐱调用出错%@",error);
//        NSString * errStr = [NSString stringWithFormat:@"网络请求失败，错误码:%ld",(long)error.code]
//        ;
//        NSLog(@"网络请求失败，错误码:%ld",(long)error.code);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [HUD hideUIBlockingIndicator];
//
//            [HUD showAlertWithText:errStr];
//        });
//
//        failure(errStr);
//    }];
    
}

+(void)putLMK_AFNHttpSrt:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.requestSerializer.timeoutInterval = 8.f;

//    [session PUT:urlStr parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        success(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failure(error);
//    }];
}
//delete请求
+(void)deleteLMK_AFNHttpSrt:(NSString *)urlStr parameters:(id)parameters success:    (void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.requestSerializer.timeoutInterval = 15.f;
    
//    [session DELETE:urlStr parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        success(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failure(error);
//    }];
}
+ (void)setLMK_ReachabilityStatusChangeBlock:(void (^)(ReachabilityStatus status))block {
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                block(ReachabilityStatusReachableViaWiFi);
                //                NSLog(@"WIFI");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                block(ReachabilityStatusReachableViaWWAN);
                //                NSLog(@"自带网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                block(ReachabilityStatusNotReachable);
                //                NSLog(@"没有网络");
                break;
                
            case AFNetworkReachabilityStatusUnknown:
                block(ReachabilityStatusUnknown);
                //                NSLog(@"未知网络");
                break;
            default:
                break;
        }
    }];
    [mgr startMonitoring];
}



+ (NSMutableDictionary *)rulesOfParametersWithDictionary:(NSMutableDictionary *)parameters AndUrl:(NSString *)urlStr{

//    if (!parameters) {
//
//        parameters = [NSMutableDictionary dictionary];
//    }
//
//    if (![urlStr isEqualToString:[ETAPIList getAPIList].userRegistAPI] && ![urlStr isEqualToString:[ETAPIList getAPIList].userLoginAPI] && ![urlStr isEqualToString:[ETAPIList getAPIList].sendAuthCodeAPI] && ![urlStr isEqualToString:[ETAPIList getAPIList].lgrdmAPI] && ![urlStr isEqualToString:[ETAPIList getAPIList].userResetPwdAPI]) {
//
//        [parameters setObject:[GlobalKit shareKit].token?[GlobalKit shareKit].token:@"" forKey:@"token"];
//
//        [parameters setObject:[GlobalKit shareKit].passport?[GlobalKit shareKit].passport:@"" forKey:@"passport"];
//    }
//
//    if ([urlStr isEqualToString:[ETAPIList getAPIList].userRegistAPI]) {
//        [parameters setObject:APP_PID forKey:@"pid"];
//    }
//
//    [parameters setObject:APP_KEY forKey:@"appKey"];
//
//    [parameters setObject:[NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"timestamp"];
//
//    NSMutableArray *keyValueArray = [NSMutableArray array];
//
//    NSMutableArray *keyArray = [parameters allKeys].mutableCopy;
//
//    [keyArray sortUsingSelector:@selector(compare:)];
//
//    for (NSString *key in keyArray) {
//
//        [keyValueArray addObject:[NSString stringWithFormat:@"%@=%@",key,parameters[key]]];
//
//    }
//
//    NSString *sign = [[NSString stringWithFormat:@"%@%@",[keyValueArray componentsJoinedByString:@"&"],APP_SECRET] md5Digest];
//
//    [parameters setObject:sign forKey:@"sign"];
    
    return parameters;
    
}

+ (NSString *)getErrorMsgByErrorCode:(NSString *)errorCode{
    
//    NSString *errorMsg;
//    if (![errorCode isKindOfClass:[NSNull class]]) {
//        switch ([errorCode integerValue]) {
//            case REQUEST_PARAMS_CHECK_ERROR:
//            {
//                errorMsg = @"网络不给力";
//
//            }
//                break;
//
//            case REQUEST_RANDOM_ERROR:
//            {
//                errorMsg = @"登录失败";
//            }
//                break;
//            case SYSTEM_ERROR:
//            {
//                errorMsg = @"网络不给力";
//            }
//                break;
//            case NOT_LOGIN:
//            {
//
//                [[GlobalKit shareKit] clearSession];
//
//                [ETLMKSOCKETMANAGER disconnectSocket];
//
//                [APP_DEV_MANAGER allDeviceLoginout];
//
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                ETLoginNavViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"ETLoginNavController"];
//
//                AppDelegate *delete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
//                [delete.window setRootViewController:loginVC];
//                errorMsg = @"您尚未登录";
//
//            }
//
//                break;
//
//            case ACCESS_TOKEN_OVERDUE:
//
//            {
//                [[GlobalKit shareKit] clearSession];
//
//                [ETLMKSOCKETMANAGER disconnectSocket];
//
//                [APP_DEV_MANAGER allDeviceLoginout];
//
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                ETLoginNavViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"ETLoginNavController"];
//
//                AppDelegate *delete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
//                [delete.window setRootViewController:loginVC];
//                errorMsg = @"登录已失效";
//            }
//                break;
//            case DEVICE_QUERY_TIMEOUT:{
//
//                errorMsg = @"设备查询失败";
//
//            }
//                break;
//            case SETTING_FAIL:{
//
//                errorMsg = @"配置不成功";
//
//            }
//                break;
//            case GW_NOT_ONLINE:{
//
//                errorMsg = @"智慧中心不在线";
//
//            }
//                break;
//            case GW_RESPONSE_TIMEOUT:{
//
//                errorMsg = @"智慧中心响应超时";
//
//            }
//                break;
//            case GW_GET_VERSION_FAIL:{
//
//                errorMsg = @"获取当前版本失败";
//
//            }
//                break;
//            case GW_NOT_ADD:{
//
//                errorMsg = @"未添加智慧中心";
//
//            }
//                break;
//            case GW_EXISTED:{
//
//                errorMsg = @"智慧中心已存在";
//
//            }
//                break;
//            case GW_NAME_REPEATE:{
//
//                errorMsg = @"智慧中心名称已存在";
//
//            }
//                break;
//            case GW_NOT_HAVE:{
//
//                errorMsg = @"您无此智慧中心";
//
//            }
//                break;
//            case WIFI_NOT_ONLINE:{
//
//                errorMsg = @"设备不在线";
//
//            }
//                break;
//            case GW_PWD_CHECK_FAIL:{
//
//                errorMsg = @"智慧中心密码验证失败";
//
//            }
//                break;
//            case INVALID_CMD:{
//
//                errorMsg = @"无效的指令";
//
//            }
//                break;
//            case DEVICE_ID_NOT_EXIST:{
//
//                errorMsg = @"设备不存在";
//
//            }
//                break;
//            case MATCH_CODE_ERROR:{
//
//                errorMsg = @"配对码错误";
//
//            }
//                break;
//
//            case MATCH_FAIL:{
//
//                errorMsg = @"配对失败";
//
//            }
//                break;
//            case GW_DEVICE_TYPE_ERROR:{
//
//                errorMsg = @"设备类型不匹配";
//
//            }
//                break;
//
//            case GW_DEVICE_NOT_MATCH:{
//
//                errorMsg = @"设备未配对";
//
//            }
//                break;
//
//            case DEVICE_SET_TIMEOUT:{
//
//                errorMsg = @"设置不成功";
//
//            }
//                break;
//
//            case SET_GROUP_INFO_FAIL:{
//
//                errorMsg = @"设置组信息失败";
//
//            }
//                break;
//
//            case SET_FAN_SPEED_FAIL:{
//
//                errorMsg = @"请将空调切换到制冷或制热模式下设置风速";
//
//            }
//                break;
//
//            case BIND_GW_OLD_PWD_ERROR:{
//
//                errorMsg = @"智慧中心旧密码不正确";
//
//            }
//                break;
//
//            case MODIFY_GW_PWD_FAIL:{
//
//                errorMsg = @"修改智慧中心密码失败";
//
//            }
//                break;
//
//            case UP_GW_FILE_ERROR:{
//
//                errorMsg = @"更新系统文件错误";
//
//            }
//                break;
//
//            case UP_GW_FAIL:{
//
//                errorMsg = @"更新系统失败";
//
//            }
//                break;
//
//            case CREATE_VISITOR_MODE_FAIL:{
//
//                errorMsg = @"访客模式创建失败";
//
//            }
//                break;
//
//            case GET_NETWORK_MODE_FAIL:{
//
//                errorMsg = @"获取网络模式失败";
//
//            }
//                break;
//
//            case MODIFY_NETWORK_MODE_FAIL:{
//
//                errorMsg = @"修改网络模式失败";
//
//            }
//                break;
//
//            case DEVICE_OFFLINE:{
//
//                errorMsg = @"设备不在线";
//
//            }
//                break;
//            case MODIFY_SSID_PWD_FAIL:{
//
//                errorMsg = @"修改SSID密码失败";
//
//            }
//                break;
//
//
//            case GET_SSID_PWD_FAIL:{
//
//                errorMsg = @"获取SSID密码失败";
//
//            }
//                break;
//
//
//            case GET_IP_FAIL:{
//
//                errorMsg = @"获取IP地址失败";
//
//            }
//                break;
//
//            case SET_IP_FAIL:{
//
//                errorMsg = @"设置IP地址失败";
//
//            }
//                break;
//
//
//            case SET_MUSIC_PARAM_INVALID:{
//
//                errorMsg = @"设置音乐参数无效";
//
//            }
//                break;
//
//            case GET_GW_VERSION_FAIL:{
//
//                errorMsg = @"获取版本信息失败";
//
//            }
//                break;
//            case USERNAME_FORMAT_ERROR:{
//
//                errorMsg = @"用户名格式错误";
//
//            }
//                break;
//            case USER_PWD_FORMAT_ERROR:{
//
//                errorMsg = @"密码格式错误";
//
//            }
//                break;
//            case USER_OLD_PWD_FORMAT_ERROR:{
//
//                errorMsg = @"旧密码格式错误";
//
//            }
//                break;
//            case USER_OLD_PWD_ERROR:{
//
//                errorMsg = @"旧密码错误";
//
//            }
//                break;
//            case NEW_OLD_PWD_SAME:{
//
//                errorMsg = @"新旧密码相同";
//
//            }
//                break;
//            case MOBILE_PHONE_IS_EMPTY:{
//
//                errorMsg = @"手机号为空";
//
//            }
//                break;
//            case USER_REGISTED:{
//
//                errorMsg = @"该用户已注册";
//
//            }
//                break;
//            case USER_NOT_REGIST:{
//
//                errorMsg = @"该用户未注册";
//
//            }
//                break;
//            case SEND_CHECK_CODE_TYPE_ERROR:{
//
//                errorMsg = @"获取验证码类型错误";
//
//            }
//                break;
//            case SEND_CHECK_CODE_IS_EMPTY:{
//
//                errorMsg = @"验证码为空";
//
//            }
//                break;
//            case SEND_CHECK_CODE_ERROR:{
//
//                errorMsg = @"验证码错误";
//
//            }
//                break;
//            case USER_NAME_PWD_ERROR:{
//
//                errorMsg = @"用户名密码错误";
//
//            }
//                break;
//            case USER_PWD_ERROR:{
//
//                errorMsg = @"用户密码错误";
//
//            }
//                break;
//            case MOBILE_PHONE_ERROR:{
//
//                errorMsg = @"手机号错误";
//
//            }
//                break;
//            case USER_NOT_EXIST:{
//
//                errorMsg = @"用户不存在";
//
//            }
//                break;
//            case MESSAGE_NOT_EXIST:{
//
//                errorMsg = @"无此消息";
//
//            }
//                break;
//            case SMS_SEND_FAIL:{
//
//                errorMsg = @"短信发送失败";
//
//            }
//                break;
//            case MESSAGE_HANDLED:{
//
//                errorMsg = @"消息已处理";
//
//            }
//                break;
//            case DEVICE_TYPE_ERROR:{
//
//                errorMsg = @"设备类型错误";
//
//            }
//                break;
//            case DEVICE_NOT_EXIST:{
//
//                errorMsg = @"设备不存在";
//
//            }
//                break;
//            case DEVICE_NAME_EXIST:{
//
//                errorMsg = @"设备名称已存在";
//
//            }
//                break;
//            case DEVICE_NOT_MATCH:{
//
//                errorMsg = @"未配对";
//
//            }
//                break;
//            case PARENT_DEVICE_NOT_EXIST:{
//
//                errorMsg = @"父设备不存在";
//
//            }
//                break;
//            case PARENT_DEVICE_NOT_MATCH:{
//
//                errorMsg = @"父设备未配对";
//
//            }
//                break;
//            case DEVICE_DETAIL_FORMAT_ERROR:{
//
//                errorMsg = @"设备详情格式错误";
//
//            }
//                break;
//            case DEVICE_MATCHSTATUS_ERROR:{
//
//                errorMsg = @"配对状态错误";
//
//            }
//                break;
//            case NOT_HAVE_DEVICE:{
//
//                errorMsg = @"无此设备";
//
//            }
//                break;
//            case DEVICE_MATCHED:{
//
//                errorMsg = @"设备已配对";
//
//            }
//                break;
//            case DEVICE_MATCH_FAIL:{
//
//                errorMsg = @"配对失败";
//
//            }
//                break;
//            case DEVICE_STATUS_ERROR:{
//
//                errorMsg = @"设备状态错误";
//
//            }
//                break;
//            case DEVICE_PARAMS_MISSING:{
//
//                errorMsg = @"设备参数不完整";
//
//            }
//                break;
//            case DEVICE_PWD_SETED:{
//
//                errorMsg = @"设备密码已设置";
//
//            }
//                break;
//            case DEVICE_PWD_ERROR:{
//
//                errorMsg = @"设备密码错误";
//
//            }
//                break;
//            case SCENE_NOT_DEVICE:{
//
//                errorMsg = @"无情景设备";
//
//            }
//                break;
//            case LINK_NAME_IS_EXIST:{
//
//                errorMsg = @"联动名称已存在";
//
//            }
//                break;
//            case LINK_DEVICE_REPEATE:{
//
//                errorMsg = @"设备重复";
//
//            }
//                break;
//            case LINK_NOT_CONDITION:{
//
//                errorMsg = @"无联动条件";
//
//            }
//                break;
//            case LINK_CONDITION_ONLY_ONE:{
//
//                errorMsg = @"联动条件唯一";
//
//            }
//                break;
//            case LINK_NOT_ACTION:{
//
//                errorMsg = @"无联动行为";
//
//            }
//                break;
//            case DEVICE_EXIST_OTHER_LINK:{
//
//                errorMsg = @"已存在与其它联动中";
//
//            }
//                break;
//            case NOT_LINK:{
//
//                errorMsg = @"无此联动";
//
//            }
//                break;
//            case NOT_SCENE:{
//
//                errorMsg = @"无此情景";
//
//            }
//                break;
//            case DEVICE_EXIST_OTHER_SCENE:{
//
//                errorMsg = @"存在其它情景中";
//
//            }
//                break;
//            case SCENE_EXISTED:{
//
//                errorMsg = @"情景名称已存在";
//
//            }
//                break;
//            case SCENE_NOT_EXIST:{
//
//                errorMsg = @"情景不存在";
//
//            }
//                break;
//            case SCENE_DEVICE_REPEATE:{
//
//                errorMsg = @"设备重复";
//
//            }
//                break;
//            case SCENE_ORDER_ERROR:{
//
//                errorMsg = @"情景顺序错误";
//
//            }
//                break;
//            case SCENE_START_FAIL:{
//
//                errorMsg = @"开启情景失败";
//
//            }
//                break;
//            case INVITE_CODE_ERROR:{
//
//                errorMsg = @"邀请码错误";
//
//            }
//                break;
//            case INVITE_CODE_USED:{
//
//                errorMsg = @"分享已获取";
//
//            }
//                break;
//            case SHARE_OUT_OF_RANG:{
//
//                errorMsg = @"超出分享数量";
//
//            }
//                break;
//            case SHARE_GET_FAIL:{
//
//                errorMsg = @"获取分享失败";
//
//            }
//                break;
//            case NOT_SHARED_TO_USER:{
//
//                errorMsg = @"未分享给此用户";
//
//            }
//                break;
//            case NOT_HAVE_ROOM:{
//
//                errorMsg = @"无此房间";
//
//            }
//                break;
//            case ROOM_DETAIL_FORMAT_ERROR:{
//
//                errorMsg = @"房间信息错误";
//
//            }
//                break;
//            case ROOM_EXISTED:{
//
//                errorMsg = @"房间已存在";
//
//            }
//                break;
//            case ROOM_NAME_REPEATE:{
//
//                errorMsg = @"房间名重复";
//
//            }
//                break;
//            case ROOM_ORDER_ERROR:{
//
//                errorMsg = @"房间顺序错误";
//
//            }
//                break;
//            case TIMING_NOT_EXIST:{
//
//                errorMsg = @"无法操作该定时";
//
//            }
//                break;
//            case TIMING_TIME_MISSING:{
//
//                errorMsg = @"定时时间为空";
//
//            }
//                break;
//            case TIMING_TIME_ERROR:{
//
//                errorMsg = @"定时时间设置错误";
//
//            }
//                break;
//            case TIMING_REPEATE:{
//
//                errorMsg = @"定时重复";
//
//            }
//                break;
//            case TIMING_CLASH:{
//
//                errorMsg = @"定时冲突";
//
//            }
//                break;
//            case OUT_OF_RANG:{
//
//                errorMsg = @"设备关联数超出限制";
//
//            }
//                break;
//            case GW_RES_HANDLE_EXCP:{
//
//                errorMsg = @"网络不给力";
//
//            }
//                break;
//            case DB_INSERT_RESULT_0:{
//
//                errorMsg = @"网络不给力";
//
//            }
//                break;
//            case DB_UPDATE_RESULT_0:{
//
//                errorMsg = @"网络不给力";
//
//            }
//                break;
//            case DB_GET_SEQ_NEXT_VALUE_ERROR:{
//
//                errorMsg = @"网络不给力";
//
//            }
//                break;
//            case HK_GET_ACCESS_TOKEN_FAIL:{
//
//                errorMsg = @"获取访问海康设备token失败";
//
//            }
//                break;
//            case VERSION_IS_OUTTIME:{
//
//                errorMsg = @"升级超时";
//
//            }
//                break;
//            case VERSION_IS_UPDATING:{
//
//                errorMsg = @"正在升级中";
//
//            }
//                break;
//            case VERSION_IS_CANUPDATE:{
//
//                errorMsg = @"有可升级版本";
//
//            }
//                break;
//
//            case WIFI_TIMEOUT:{
//
//                errorMsg = @"设备响应超时";
//
//            }
//                break;
//
//            case SWITCH_INSCENE:{
//
//                errorMsg = @"开关已在自己或他人情景中";
//
//            }
//                break;
//            case SWITCH_INMANYLINK:{
//
//                errorMsg = @"开关已在多联中";
//
//            }
//                break;
//            case SWITCH_INLINK:{
//
//                errorMsg = @"开关已在自己或他人联动中";
//
//            }
//                break;
//
//            case SCENESWITCH_EXIT:{
//
//                errorMsg = @"开关已设置为情景开关,无法设置";
//
//            }
//                break;
//
//            case SCENESWITCH_NOT_EXIT:{
//
//                errorMsg = @"情景开关不存在";
//
//            }
//                break;
//            case SCENEPWD_ERROR:{
//
//                errorMsg = @"情景密码错误";
//
//            }
//                break;
//            case SCENEPWD_EXIT:{
//
//                errorMsg = @"情景密码已设置";
//
//            }
//                break;
//
//            case DEVIEC_OTHER_ADD:{
//
//                errorMsg = @"设备已被别人添加";
//
//            }
//                break;
//
//            case SCENEDEFAULT_NOT_DEL:{
//
//                errorMsg = @"默认情景不允许删除";
//
//            }
//                break;
//
//            case SUCCESS:{
//
//                errorMsg = @"0000";
//
//            }
//                break;
//            case 4192:{
//
//                errorMsg = @"指令未执行";
//
//            }
//                break;
//            default:{
//
////                errorMsg = @"网络不给力";
//                errorMsg =  [NSString stringWithFormat:@"请求失败：%@",errorMsg];
//
//            }
//                break;
//        }
//
//    }else{
//
//        errorMsg = @"网络不给力";
//
//    }

    
    return nil;
    
}

+(void)postLMK_AFNHttpSrt:(NSString *)urlStr parameters:(NSMutableDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure{

//
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    session.responseSerializer = [AFHTTPResponseSerializer serializer];
//    session.requestSerializer.timeoutInterval = 8.f;
//
//    [session POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseObjectDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//        NSLog(@"%@",responseObjectDic);
//
//        NSMutableDictionary *response = [(NSDictionary *)responseObjectDic mutableCopy];
//        if (![responseObjectDic[@"processResult"] boolValue]) {
//            NSString *errorMsg = responseObjectDic[@"errorMsg"];
//
//            errorMsg = [self getErrorMsgByErrorCode:errorMsg];
//
//            [response setValue:errorMsg forKey:@"errorMsg"];
//        }
//
//        success(response);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        failure(error);
//
//    }];
    
}


@end
