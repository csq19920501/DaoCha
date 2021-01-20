//
//  CSQScoketService.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CSQScoketService.h"
#import "Device.h"
#import "CheckModel.h"
#import "ReportModel.h"
#import "ETAFNetworking.h"
//#import "TcpManager.h"

@interface CSQScoketService ()<GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *clientSockets;//保存客户端scoket
@property (strong, nonatomic) NSArray *testArray;
@property (assign, nonatomic) NSInteger testCount;
@property (assign, nonatomic) NSTimer * timer;
//@property(strong,nonatomic) GCDAsyncSocket *testSocket;
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
    [self test1234];
    
    
//    TcpManager *tcp = [TcpManager Share];
//
//    tcp.delegate = self;
//
//    _testSocket = tcp.asyncsocket;
//
//    if (![_testSocket connectToHost:@"http://202.107.226.68/" onPort:21008 error:nil]) {
//
//        NSLog(@"fail to connect");
//
//    }
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
                NSString *typeStr ;
                for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
                    Device *device = DEVICETOOL.deviceArr[i];
                    if(!device.selected &&  [device.id isEqualToString:idStr]){
                        return;
                    }else if([device.id isEqualToString:idStr]){
                        typeStr = device.typeStr;
                    }
                }
                
                NSMutableArray *dataArr = nil;
                CheckModel *checkModel ;
                switch ([idStr intValue]) {
                    case 1:{
                        dataArr = [DeviceTool shareInstance].deviceDataArr1;
                        checkModel = DEVICETOOL.checkModel1;
                    }
                        break;
                    case 2:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr2;
                            checkModel = DEVICETOOL.checkModel2;
                        }
                        break;
                    case 3:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr3;
                            checkModel = DEVICETOOL.checkModel3;
                        }
                        break;
                    case 11:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr4;
                            checkModel = DEVICETOOL.checkModel4;
                        }
                        break;
                    case 12:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr5;
                            checkModel = DEVICETOOL.checkModel5;
                        }
                        break;
                    default:
                        break;
                }
                //初始时间 初始时间
                NSString *dataStr = dic[@"data"];
                NSArray *reciveataArr = [dataStr componentsSeparatedByString:@","];
                NSMutableArray *checkArr = [NSMutableArray array];
                [reciveataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    long revData = (long)strtoul([obj UTF8String],0,16);  //16进制字符串转换成long
                    revData = revData - 85317;
                    NSTimeInterval  timeinterval2 = timeinterval + idx*20;
                    long a = 3000 + idx;
                    [dataArr addObject:@[@(timeinterval2),@(a)]];
//                    [[DeviceTool shareInstance].deviceDataArr2 addObject:@[@(timeinterval2),@(a)]];
//                    [[DeviceTool shareInstance].deviceDataArr3 addObject:@[@(timeinterval2),@(a)]];
//                    [[DeviceTool shareInstance].deviceDataArr4 addObject:@[@(timeinterval2),@(a)]];
//                    [[DeviceTool shareInstance].deviceDataArr5 addObject:@[@(timeinterval2),@(a)]];
                    [checkArr addObject:@(revData)];
                }];
                
                switch ([idStr intValue]) {
                    case 1:{
                        if(!DEVICETOOL.checkModel1){
                            DEVICETOOL.checkModel1 = [[CheckModel alloc]init];
                        }
                        [self checkData:checkArr withModel:DEVICETOOL.checkModel1 withTypeStr:typeStr  withId:[idStr intValue]];
                    }
                        break;
                    case 2:
                        {
               
                            if(!DEVICETOOL.checkModel2){
                                DEVICETOOL.checkModel2 = [[CheckModel alloc]init];
                            }
                            [self checkData:checkArr withModel:DEVICETOOL.checkModel2 withTypeStr:typeStr withId:[idStr intValue]];
                        }
                        break;
                    case 3:
                        {
                            if(!DEVICETOOL.checkModel3){
                                DEVICETOOL.checkModel3 = [[CheckModel alloc]init];
                            }
                             [self checkData:checkArr withModel:DEVICETOOL.checkModel3 withTypeStr:typeStr withId:[idStr intValue]];
                        }
                        break;
                    case 11:
                    {
                            if(!DEVICETOOL.checkModel4){
                                DEVICETOOL.checkModel4 = [[CheckModel alloc]init];
                            }
                            [self check56Data:checkArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"定位闭锁力" withId:[idStr intValue]] ;
                        }
                        break;
                    case 12:
                        {
                            if(!DEVICETOOL.checkModel5){
                                DEVICETOOL.checkModel5 = [[CheckModel alloc]init];
                            }
                            [self check56Data:checkArr withModel:DEVICETOOL.checkModel5 withTypeStr:@"定位闭锁力" withId:[idStr intValue]];
                        }
                        break;
                    default:
                        break;
                }
                
//                if(!checkModel){
//                    checkModel = [[CheckModel alloc]init];
//                }
//                if(checkModel == DEVICETOOL.checkModel4 ){
//                    [self check56Data:checkArr withModel:checkModel withTypeStr:@"定位闭锁力"];
//                }
//                else if( checkModel == DEVICETOOL.checkModel5){
//                    [self check56Data:checkArr withModel:checkModel withTypeStr:@"反位闭锁力"];
//                }
//                else{
//                     [self checkData:checkArr withModel:checkModel withTypeStr:typeStr];
//                }
               
            });
}
-(void)test1234{
    _testCount = 0;
    __weak typeof(self) weakSelf = self;
    NSString *url = @"http://118.31.39.28:21006/getresistance.cpp?starttime=2021-01-20%2002:51:00&endtime=2021-01-20%2002:51:20&IMEI=860588048931334&name=%E6%99%AE%E5%AE%8914%E5%8F%B7%E5%B2%94%E5%BF%83&idx=0&timestamp=1611107677743&idxname=X2";
    NSString *url2 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2010:20:07&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";
    [ETAFNetworking getLMK_AFNHttpSrt:url2 andTimeout:8.f andParam:nil success:^(id responseObject) {
        NSArray *series = responseObject[@"series"];
        if(series.count>2){
            weakSelf.testArray = series[2][@"data"];
            NSLog(@"获取到的历史数据数量%ld  %@ %@ ",weakSelf.testArray.count,series[2][@"name"],series[2][@"data"]);
             self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(test) userInfo:nil repeats:YES];
        }
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideUIBlockingIndicator];
        });
       

    } WithHud:YES AndTitle:nil];
    
   
   
}
-(void)test{
    if(!DEVICETOOL.checkModel1){
        NSLog(@"生成DEVICETOOL.checkModel1");
        DEVICETOOL.checkModel1 = [[CheckModel alloc]init];
    }
//    CheckModel *checkModel = DEVICETOOL.checkModel1;
    NSMutableArray *testArr = [NSMutableArray array];
    if(_testCount + 50 < self.testArray.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray[a];
            [testArr addObject:data[1]];
        }
    }else{
        for (long a = _testCount; a< self.testArray.count; a++) {
            NSArray *data = self.testArray[a];
            NSString *dataStr = data[1];
            long dataLong = [dataStr longLongValue];
            NSNumber *num = [NSNumber numberWithLongLong:dataLong];
            [testArr addObject:num];
        }
    }
    [self checkData:testArr withModel:DEVICETOOL.checkModel1 withTypeStr:@"J1" withId:1];
    _testCount = _testCount + 50;
    if(self.testCount > self.testArray.count){
        [self.timer invalidate];
        self.timer = nil;
    }
   
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
//检测56类型
-(void)check56Data:(NSArray <NSNumber*>*)dataArr withModel:(CheckModel*)model withTypeStr:(NSString*)typeStr withId:(NSInteger)id{
    if(dataArr.count > 15){
        if(!model.startValue){
               long long sum = 0;
               for(int i=0 ;i<5;i++){
                   NSNumber *number = dataArr[i];  //调试修改
                   sum += number.longValue;        //调试修改
               }
               model.startValue = sum/5;
            NSLog(@"前五个数据生成model.startValue = %ld",model.startValue);
        }
        
        long min = 100000;
        long max = -100000;
        long sun = 0;
        for (NSNumber *number in dataArr) {
            long num = number.longValue - model.startValue;
            sun += num;
            if(num < min){
                min = num;
            }
            if(num > max){
                max = num;
            }
        }
        if(min < model.min){
            model.min = min;
        }
        if(max > model.max){
            model.max = max;
        }
        
        long mean = sun/(int)dataArr.count;
        long meanSum = 0;
        for (NSNumber *number in dataArr) {
            long num = number.longLongValue - model.startValue;
            meanSum += (num - mean)*(num - mean);
        }
        long average = meanSum/(int)dataArr.count;
        NSLog(@"average = %ld",average);
        if(average <100){
            if(model.closeChange_OK){
                model.stableValue = mean;
                if(!model.closeStable1_OK){
                    model.closeStable1_OK = YES;
                }else if(!model.closeStable2_OK){
                    model.closeStable2_OK = YES;
                    
                    if(model.stableValue - model.closeValue > 2800 || model.stableValue - model.closeValue < -2800){
                        NSLog(@"检测到变化大于2800，舍弃");
                        [self setCheckNilWith:id];
                        return;
                    }
                    long allMin = 100000;
                    long allMax = -100000;
                    long allSun = 0;
                    for (NSNumber *number in model.dataArr) {
                        long num = number.longValue ;
                        allSun += num;
                        if(num < allMin){
                            allMin = num;
                        }
                        if(num > allMax){
                            allMax = num;
                        }
                    }
                    if(allMax-model.closeValue > 2800 || allMax-model.stableValue > 2800){
                        NSLog(@"检测到allMax-closeValue||stableValue>2800，舍弃");
                        [self setCheckNilWith:id];
                        return;
                    }
                    //闭锁力 生成
                    ReportModel *dataModel = [[ReportModel alloc]init];
                    dataModel.station = DEVICETOOL.stationStr;
                    dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                    dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,@"闭锁力"];
                    dataModel.deviceType = typeStr;
                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                    dataModel.timeLong = currentTime;
                    if([typeStr isEqualToString:@"定位闭锁力"]){
                        dataModel.reportType = 5;
                        dataModel.atresia_ding = model.closeValue;
                        dataModel.keep_ding = model.stableValue;
                    }else{
                        dataModel.reportType = 6;
                        dataModel.atresia_fan = model.closeValue;
                        dataModel.keep_fan = model.stableValue;
                    }
                    [self setCheckNilWith:id];
                    [[LPDBManager defaultManager] saveModels: @[dataModel]];
                }
            }else{
                model.close1_OK = YES;
                model.closeValue = mean;
            }
        }else{
            if(!model.closeChange_OK){
//                            波动开始
                            model.step1_OK = YES;
                            NSDate *now = [NSDate date];
                            NSTimeInterval nowInt = [now timeIntervalSince1970];
                            model.startTime = nowInt;
            }
            model.closeChange_OK = YES;

            [model.dataArr addObjectsFromArray:dataArr];
        }
    }
};
//检测1234类型
-(void)checkData:(NSArray <NSNumber*>*)dataArr withModel:(CheckModel*)model withTypeStr:(NSString*)typeStr withId:(NSInteger)id{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        
        
    if(dataArr.count > 10){
        if(model.startValue == -10000){
               long long sum = 0;
               for(int i=0 ;i<5;i++){
                    NSNumber *number = dataArr[i];  //调试修改
                    sum += number.longValue;        //调试修
               }
               model.startValue = sum/5;
               NSLog(@"前五个数据生成model.startValue = %ld",model.startValue);
        }

        long min = 100000;
        long max = -100000;
        long sun = 0;
        for (NSNumber *number in dataArr) {
            long num = number.longValue - model.startValue;
            sun += num;
//            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
            if(num < min){
                min = num;
            }
            if(num > max){
                max = num;
            }
        }
        if(min < model.min){
            model.min = min;
        }
        if(max > model.max){
            model.max = max;
        }
        
        long mean = sun/(int)dataArr.count;
        
        NSLog(@"mean = %ld min = %ld max=%ld",mean,min,max);
        long meanSum = 0;
        for (NSNumber *number in dataArr ) {
            long num = number.longValue - model.startValue;
            if((num - mean)>0){
                meanSum += (num - mean);
            }else{
                meanSum += (mean - num);
            }
//            meanSum += (num - mean)*(num - mean);
        }
        long average = meanSum/(int)dataArr.count;
        NSLog(@"average = %ld",average);
        if(average > 70){
            
           
            if(average > 400){
                if(!model.step2_OK){
                    //小变化没两秒就急速升高则是受阻空转后错误曲线
                    model.blockedError = YES;
                    if(mean > 0){
                        model.blockedErrorTypeUp = YES;
                    }
                     NSLog(@"average > 400  model.blockedError = YES");
                }else{
                    if(!model.blockedChange1_OK){
                        model.blockedChange1_OK = YES;
                        NSLog(@"average > 400  model.blockedChange_OK = YES");
                    }else{
                        if(model.blockedStable2_OK){
                            model.blockedChange2_OK = YES;
                             NSLog(@"average > 400  model.blockedChange2_OK = YES");
                        }
                    }
                }
                
            }else{
                if(!model.step1_OK){
                               //波动开始
                               model.step1_OK = YES;
                               NSDate *now = [NSDate date];
                               NSTimeInterval nowInt = [now timeIntervalSince1970];
                               model.startTime = nowInt;
                                NSLog(@"average > 70 波动开始 model.step1_OK = YES");
                           }
                           else if (!model.step2_OK){
                               model.step2_OK = YES;
                               NSLog(@"average > 70  model.step2_OK = YES");
                           }
                           else if (!model.step3_OK){
                               model.step3_OK = YES;
                               NSLog(@"average > 70  model.step3_OK = YES");
                           }
                           else if (!model.step4_OK){
                               model.step4_OK = YES;
                               NSLog(@"average > 70  model.step4_OK = YES");
                           }
            }
            [model.dataArr addObjectsFromArray:dataArr];
        }else{
            if(mean  > 2000 || mean  < -2000){
                [model.dataArr addObjectsFromArray:dataArr];
                if(!model.blockedStable1_OK){
                    model.blockedStable1_OK = YES;
                    NSLog(@"average < 70  model.blockedStable1_OK = YES");
                }
               else if(!model.blockedStable2_OK){
                    model.blockedStable2_OK = YES;
                    NSLog(@"average < 70  model.blockedStable2_OK = YES");
                }
                else if(!model.blockedStable3_OK){
                   
                    model.blockedStable3_OK = YES;

                    //受阻空转生成
                    ReportModel *dataModel = [[ReportModel alloc]init];
                    dataModel.station = DEVICETOOL.stationStr;
                    dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                    dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                    dataModel.deviceType = typeStr;
                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                    dataModel.timeLong = currentTime;
                    
                    if(mean < model.startValue){
                        model.blocked_max = min;
                        dataModel.reportType = 2;
                        dataModel.blocked_Top = model.min + model.startValue;
                         NSLog(@"average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
                    }else{
                         model.blocked_max = max;
                        dataModel.reportType = 4;
                        dataModel.blocked_Top = model.max + model.startValue;
                        NSLog(@"average < 70  model.blockedStable2_OK = YES 反扳定受阻空转生成");
                    }
                    dataModel.blocked_stable = mean + model.startValue;
                    [[LPDBManager defaultManager] saveModels: @[dataModel]];
//                    [self setCheckNilWith:id];
                    return;
                }
                
            }else{
                if(model.step3_OK){
                    //波动结束
                    NSDate *now = [NSDate date];
                    NSTimeInterval nowInt = [now timeIntervalSince1970 ];
                    model.endTime = nowInt;
                    
                    if(model.blockedChange2_OK || model.blockedStable3_OK){
                        NSLog(@"受阻空转后恢复平稳值 清空掉model");
                        [self setCheckNilWith:id];
                        return;
                    }
                    
                    if(!model.blockedStable3_OK){

                                            long allMin = 100000;
                                            long allMax = -100000;
                                            long allSun = 0;
                                            for (NSNumber *number in model.dataArr) {
                                                long num = number.longValue ;
                                                allSun += num;
                                                if(num < allMin){
                                                    allMin = num;
                                                }
                                                if(num > allMax){
                                                    allMax = num;
                                                }
                                            }
                                            long  allMean = (long)allSun/(int)model.dataArr.count;
                                            long openInt = (long)(dataArr.count * (1./5.5));
                                            long transformInt = (long)(dataArr.count * (3.5/5.5));
                                            long closeInt = dataArr.count - openInt - transformInt;
                                             
                        NSLog(@"检测到扳动 allMean = %ld allMin = %ld allMax=%ld",allMean,allMin,allMax);
                        
                                              long halfMean;
                                               long halfSum = 0;
                        if(!model.blockedError){
                            for(long i =0; i<model.dataArr.count/2;i++){
                                NSNumber *number = model.dataArr[i];
                                long num = number.longValue ;
                                halfSum += num;
                            }
                             halfMean = halfSum/(int)model.dataArr.count/2;
                        }else{
                            NSLog(@"model.dataArr.coun = %ld",model.dataArr.count);
                            long aa= 0;
                            for(NSNumber *number in model.dataArr){
                                long num = number.longValue ;
                                if(model.blockedErrorTypeUp) //错误类型上往上突出
                                {
                                    if(num < model.startValue){
                                        halfSum += num;
                                        aa++;
                                    }
                                }else{
                                    if(num > model.startValue){
                                        halfSum += num;
                                        aa++;
                                    }
                                }
                            }
                            halfMean = (int)halfSum/aa ;
                            
                            if(model.dataArr.count > 50){
//                                for(long i =(long)model.dataArr.count/3; i<(long)model.dataArr.count*2/3;i++){
//                                    NSNumber *number = model.dataArr[i];
//                                    long num = number.longValue ;
//                                    halfSum += num;
//                                }
//                                 halfMean = halfSum/(int)model.dataArr.count/3 ;
                            }else{
                                if(model.step1_OK){
                                    NSLog(@"短波动 舍弃掉");
                                    [self setCheckNilWith:id];
                                }
                                return;
                            }
                        }
                                               
                                             
                        
                                            if(halfMean < model.startValue){
                                                NSLog(@"检测到定扳反 halfMean=%ld model.startValue = %ld ",halfMean,model.startValue);
                                                if(allMax - halfMean > 2500){
                                                    NSLog(@"检测到定扳反 但是halfMean=%ld -平均值>2500，放弃掉 受阻空转后会出现错误曲线",halfMean);
                                                    [self setCheckNilWith:id];
                                                    return;
                                                }
                                            }else{
                                                NSLog(@"检测到反扳定 halfMean=%ld model.startValue = %ld ",halfMean,model.startValue);
                                               if(allMin - halfMean < -2500){
                                                   NSLog(@"检测到反扳定 但是最小值-平均值<-2500，放弃掉");
                                                   [self setCheckNilWith:id];
                                                   return;
                                               }
                                            }
                        
                        //转换阻力正常 生成
                        ReportModel *dataModel = [[ReportModel alloc]init];
                                           dataModel.station = DEVICETOOL.stationStr;
                                           dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                           dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                           dataModel.deviceType = typeStr;
                                           long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                           dataModel.timeLong = currentTime;
                        
                                            
                        
                        long openMin = 100000;
                        long openMax = -100000;
                        long openSun = 0;
                        for(long i =0; i<openInt;i++){
                            NSNumber *number = model.dataArr[i];
                            long num = number.longValue ;
                            openSun += num;
                            if(num < openMin){
                                openMin = num;
                            }
                            if(num > openMax){
                                openMax = num;
                            }
                        }
                        long  openMean = (long)openSun/openInt;
                        
                        long transformMin = 100000;
                        long transformMax = -100000;
                        //nihaolihaideganhuo
                        long transformSun = 0;
                        for(long i =openInt; i<openInt + transformInt;i++){
                            NSNumber *number = model.dataArr[i];
                            long num = number.longValue ;
                            transformSun += num;
                            if(num < transformMin){
                                transformMin = num;
                            }
                            if(num > transformMax){
                                transformMax = num;
                            }
                        }
                        long  transformMean = (long)transformSun/transformInt;
                        
                        long closeMin = 100000;
                        long closeMax = -100000;
                        long closeSun = 0;
                        for(long i =openInt + transformInt; i<dataArr.count;i++){
                            NSNumber *number = model.dataArr[i];
                            long num = number.longValue ;
                            closeSun += num;
                            if(num < closeMin){
                                closeMin = num;
                            }
                            if(num > closeMax){
                                closeMax = num;
                            }
                        }
                        long  closeMean = (long)closeSun/closeInt;
                        
//                        long beforeAfterMean = (openMean + closeMean )/2;
                        
                       
                        
                                           if(halfMean < model.startValue){
                                               dataModel.reportType = 1;
                                               dataModel.all_Top = model.min + model.startValue;
                                               dataModel.all_mean = allMean;
                                               
                                               dataModel.open_Top = openMin;
                                               dataModel.open_mean = openMean;
                                               
                                               dataModel.transform_Top = transformMin;
                                               dataModel.transform_mean = transformMean;
                                               
                                               dataModel.close_Top = closeMin;
                                               dataModel.close_mean = closeMean;
                                               NSLog(@" 定扳反 halfMean= %ld  model.startValue= %ld", halfMean,model.startValue);
                                           }else{
                                               dataModel.reportType = 3;
                                               dataModel.all_Top = model.max + model.startValue;
                                               dataModel.all_mean = allMean;
                                               
                                               dataModel.open_Top = openMax;
                                               dataModel.open_mean = openMean;
                                               
                                               dataModel.transform_Top = transformMax;
                                               dataModel.transform_mean = transformMean;
                                               
                                               dataModel.close_Top = closeMax;
                                               dataModel.close_mean = closeMean;
                                               NSLog(@" 反扳定 halfMean= %ld  model.startValue= %ld", halfMean,model.startValue);
                                           }
                                            
                                            NSLog(@"average < 100  波动结束 !model.blockedStable2_OK  正常阻力转换生");
                                         
                                           [[LPDBManager defaultManager] saveModels: @[dataModel]];
                        [self setCheckNilWith:id];
                        return;
                        
                    }
                }else{
                    if(model.step1_OK){
                        NSLog(@"小波动 舍弃掉");
                        [self setCheckNilWith:id];
                    }
                    return;
                }
            }
            
            
            if(!model.step1_OK){
                NSLog(@"检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
                model.startValue = mean;
            }
        }
    }
  });
}
-(void)setCheckNilWith:(NSInteger)id{
                       if(id == 1){
                           DEVICETOOL.checkModel1 = nil;
                       }
                       else if(id == 2){
                           DEVICETOOL.checkModel2 = nil;
                       }
                       if(id == 3){
                           DEVICETOOL.checkModel3 = nil;
                       }
                       else if(id == 11){
                           DEVICETOOL.checkModel4 = nil;
                       }
                       if(id == 12){
                           DEVICETOOL.checkModel5 = nil;
                       }
}

////链接服务器成功回调
//
//- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
//
////    if (self.time == nil) {
////
////        self.time = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkLongConnectByServe) userInfo:nil repeats:YES];
////
////        [self.time fire];
////
////    }
//
//}
//
//
//
//// 心跳连接
//
//-(void)checkLongConnectByServe{
//
//    // 向服务器发送固定可是的消息，来检测长连接
//
//    NSString *longConnect = @"ping";
//
//    NSData   *data  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
//
//    [_testSocket writeData:data withTimeout:3 tag:1];
//
//    [_testSocket readDataWithTimeout:30 tag:2];
//
//}
//
////收到信息回调
//
//-(void)testSocket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
//
//    NSString * string = [[NSString alloc]
//
//                         initWithData:data encoding:NSUTF8StringEncoding];
//
//    NSLog(@"didReadData===========>%@",string);
//
//}
//
//
//
//-(void)testSocket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
//
//    NSLog(@"===========>didAcceptNewSocket");
//
//}
//
//-(void)testSocketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
//
//    NSLog(@"===========>断开了");
//
//}
//
// //信息发送成功回调
//
//-(void)testSocket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
//
//    NSLog(@"===========>写入成功");
//
//}

@end

