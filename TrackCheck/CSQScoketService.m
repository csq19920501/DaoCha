//
//  CSQScoketService.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CSQScoketService.h"
#import "Device.h"

@interface CSQScoketService ()<GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *clientSockets;//保存客户端scoket
@end
@implementation CSQScoketService
- (NSMutableArray *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [[NSMutableArray alloc]init];
    }
    return _clientSockets;
}

- (void)start
{
    //1.创建scoket对象
    GCDAsyncSocket *serviceScoket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];

    //2.绑定端口(5288)
   //端口任意，但遵循有效端口原则范围：0~65535，其中0~1024由系统使用或者保留端口，开发中建议使用1024以上的端口
    NSError *error = nil;
    [serviceScoket acceptOnPort:5288 error:&error];

    //3.开启服务(实质第二步绑定端口的同时默认开启服务)
    if (error == nil)
    {
        NSLog(@"开启成功");
    }
    else
    {
        NSLog(@"开启失败");
    }
    self.socket = serviceScoket;
}

#pragma mark GCDAsyncSocketDelegate
//连接到客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //sock 服务端的socket
    //newSocket 客户端连接的socket
    NSLog(@"新增链接%@----%@",sock, newSocket);

    //1.保存连接的客户端socket(否则newSocket释放掉后链接会自动断开)
    [self.clientSockets addObject:newSocket];

    //连接成功服务端立即向客户端提供服务
//    NSMutableString *serviceContent = [NSMutableString string];
//    [serviceContent appendString:@"话费查询请按1\n"];
//    [serviceContent appendString:@"话费充值请按2\n"];
//    [serviceContent appendString:@"投诉建议请按3\n"];
//    [serviceContent appendString:@"最新优惠请按4\n"];
//    [serviceContent appendString:@"人工服务请按0\n"];
//    [newSocket writeData:[serviceContent dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

    //2.监听客户端有没有数据上传
    //-1代表不超时
    //tag标示作用
    [newSocket readDataWithTimeout:-1 tag:0];
}

//接收到客户端数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //1.接受到用户数据
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"recv:%@",str);
    NSDictionary *dic = str.mj_JSONObject;
    NSString *cmd = dic[@"cmd"];
    
    NSString *dataStr = nil;
    if([cmd isEqualToString:@"push_msg"]){
        NSDictionary *dict =  @{@"cmd":@"push_msg_ack",@"packnum":@"0"};
        dataStr = dict.mj_JSONString;
        
        if( DEVICETOOL.testStatus != TestStarted){
            [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [sock readDataWithTimeout:-1 tag:0];
            return;
        }
        [self getData:dic];
    }
   else if([cmd isEqualToString:@"ping"]){
        NSDictionary *dict =  @{@"cmd":@"pong"};
        dataStr = dict.mj_JSONString;
       
//       [self  changeDevice:dic];
        
    }else if([cmd isEqualToString:@"time"]){
        long long currentTime = [[NSDate date] timeIntervalSince1970];
        NSNumber *time = [NSNumber numberWithLongLong:currentTime];
        NSDictionary *dict =  @{@"cmd":@"time_ack",@"timestamp":time};
        dataStr = dict.mj_JSONString;

    }else if([cmd isEqualToString:@"push_info"]){
        NSDictionary *dict =  @{@"cmd":@"push_info_ack"};
        dataStr = dict.mj_JSONString;
        
        [self  changeDevice:dic];
        
    }else if([cmd isEqualToString:@"version"]){
        long long currentTime = [[NSDate date] timeIntervalSince1970];
        NSNumber *time = [NSNumber numberWithLongLong:currentTime];
        NSDictionary *dict =  @{@"cmd":@"version_ack",@"timestamp":time};
        dataStr = dict.mj_JSONString;
    }
    
//    NSLog(@"senddataStr = %@",dataStr);
    [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [sock readDataWithTimeout:-1 tag:0];
}
-(void)getData:(NSDictionary*)dic{
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                NSString * timeStr = dic[@"time"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSDate *localDate = [dateFormatter dateFromString:timeStr];
                NSTimeInterval timeinterval = [localDate timeIntervalSince1970]*1000;
    //            NSLog(@"timeinterval 收到时间 = %@-%f",timeStr,timeinterval);
    //            long long timeinter = (long long)timeinterval;
                
                NSString * idStr = dic[@"id"];
                NSMutableArray *dataArr = nil;
                switch ([idStr intValue]) {
                    case 1:
                        dataArr = [DeviceTool shareInstance].deviceDataArr1;
                        break;
                    case 2:
                        dataArr = [DeviceTool shareInstance].deviceDataArr2;
                    break;
                    case 3:
                        dataArr = [DeviceTool shareInstance].deviceDataArr3;
                        break;
                    case 11:
                        dataArr = [DeviceTool shareInstance].deviceDataArr4;
                        break;
                    case 12:
                        dataArr = [DeviceTool shareInstance].deviceDataArr5;
                    break;
                    default:
                        break;
                }
                
                NSString *dataStr = dic[@"data"];
                NSArray *reciveataArr = [dataStr componentsSeparatedByString:@","];
                [reciveataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    long errCode = (long)strtoul([obj UTF8String],0,16);  //16进制字符串转换成long
    //                NSLog(@"%@----%ld",reciveataArr[idx],errCode);
                    NSTimeInterval  timeinterval2 = timeinterval + idx*50;
                    long a = 3000 + idx;
                    [dataArr addObject:@[@(timeinterval2),@(a)]];
                    [[DeviceTool shareInstance].deviceDataArr2 addObject:@[@(timeinterval2),@(a)]];
                    [[DeviceTool shareInstance].deviceDataArr3 addObject:@[@(timeinterval2),@(a)]];
                    [[DeviceTool shareInstance].deviceDataArr4 addObject:@[@(timeinterval2),@(a)]];
                    [[DeviceTool shareInstance].deviceDataArr5 addObject:@[@(timeinterval2),@(a)]];
                }];
            });
}
-(void)changeDevice:(NSDictionary *)dic{
    DeviceTool *delegate = [DeviceTool shareInstance];
            BOOL isExit = NO;
            for(int a = 0;a<delegate.deviceArr.count;a++){
                Device *device = delegate.deviceArr[a];
                if([device.id isEqualToString:dic[@"id"]]){
                    isExit = YES;
                }
            }
            if(!isExit){
                Device *newDevice = [[Device alloc]init];
    //            newDevice.selected = YES;
    //            newDevice.typeNum = dic[@"type"];
                newDevice.version = dic[@"version"];
                newDevice.fitstAdd = YES;
                newDevice.looked = YES;
                newDevice.id = dic[@"id"];
                NSInteger type = [newDevice.id integerValue];
                switch (type) {
//                    case 1:
//                        newDevice.typeStr = delegate.deviceNameArr[0];
//                        break;
//                    case 2:
//                        newDevice.typeStr = delegate.deviceNameArr[1];
//                        break;
//                    case 3:
//                        newDevice.typeStr = delegate.deviceNameArr[2];
//                        break;
                    case 11:
                        newDevice.typeStr = @"定位闭锁力";
                        break;
                    case 12:
                        newDevice.typeStr = @"反位闭锁力";
                        break;
                    default:
                        break;
                }
                [delegate.deviceArr addObject:newDevice];
                Device *j2 = [[Device alloc]init];
                j2 = [newDevice copy];
                j2.id = @"2";
                [delegate.deviceArr addObject:j2];
                
                Device *j3 = [[Device alloc]init];
                               j3 = [newDevice copy];
                               j3.id = @"3";
                               [delegate.deviceArr addObject:j3];
                
                [delegate.deviceArr sortedArrayUsingComparator:^(Device *obj1,Device*obj2){
                               if([obj1.id integerValue] < [obj2.id integerValue]){
                                   return NSOrderedAscending;
                               }else{
                                   return NSOrderedAscending;
                               }
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:DEVICECHANGE object:nil userInfo:nil];
            }
}
@end

