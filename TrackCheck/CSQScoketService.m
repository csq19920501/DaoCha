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

//@property(strong,nonatomic) GCDAsyncSocket *testSocket;
@end
@implementation CSQScoketService

+ (CSQScoketService *)shareInstance{
    
    static CSQScoketService *tcpSocket =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tcpSocket = [[CSQScoketService alloc] init];
    });
    return tcpSocket;
}

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
-(void)addDebugDevice{
    NSDictionary *deviceDict = @{
        @"id":@"1",
        @"version":@"sss"
    };
    [self changeDevice:deviceDict];
    
    NSDictionary *deviceDict2 = @{
        @"id":@"11",
        @"version":@"sss11"
    };
    [self changeDevice:deviceDict2];
    
    NSDictionary *deviceDict3 = @{
           @"id":@"12",
           @"version":@"sss12"
       };
    [self changeDevice:deviceDict3];
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
        
         [self  changeDevice:dic];
    
        if( DEVICETOOL.testStatus != TestStarted){
            [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [sock readDataWithTimeout:-1 tag:0];
            return;
        }
        if(!DEVICETOOL.isDebug){
             [self getData:dic];
        }
    }
    else if([cmd isEqualToString:@"ping"]){
        NSDictionary *dict =  @{@"cmd":@"pong"};
        dataStr = dict.mj_JSONString;
        
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
                
                if(DEVICETOOL.seleLook == ONE){
                    if([idStr intValue] == 11 || [idStr intValue] == 12){
                        return ;
                    }
                }else if(DEVICETOOL.seleLook == TWO){
                    if([idStr intValue] == 1 || [idStr intValue] == 2 || [idStr intValue] == 3){
                        return ;
                    }
                }
                
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
//                    long a = 3000 + idx;
                    [dataArr addObject:@[@(timeinterval2),@(revData)]];
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
                            [self check56Data:checkArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:[idStr intValue]] ;
                        }
                        break;
                    case 12:
                        {
                            if(!DEVICETOOL.checkModel4){
                                DEVICETOOL.checkModel4 = [[CheckModel alloc]init];
                            }
                            [self check56Data:checkArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:[idStr intValue]];
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
-(void)test1234_{
    
    _testCount = 0;
    __weak typeof(self) weakSelf = self;
    NSString *url = @"http://118.31.39.28:21006/getresistance.cpp?starttime=2021-01-20%2002:51:00&endtime=2021-01-20%2002:51:20&IMEI=860588048931334&name=%E6%99%AE%E5%AE%8914%E5%8F%B7%E5%B2%94%E5%BF%83&idx=0&timestamp=1611107677743&idxname=X2";
    NSString *url2 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2010:20:07&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //阻力转换
    
     NSString *url3 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2010:20:07&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //多时间
    
    [ETAFNetworking getLMK_AFNHttpSrt:url2 andTimeout:8.f andParam:nil success:^(id responseObject) {
        NSArray *series = responseObject[@"series"];
        if(series.count>2){
            weakSelf.testArray = series[2][@"data"];
            NSLog(@"获取到的历史数据数量%ld  %@ %@ ",weakSelf.testArray.count,series[2][@"name"],series[2][@"data"]);
             self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testTimer) userInfo:nil repeats:YES];
        }
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideUIBlockingIndicator];
        });
       

    } WithHud:NO AndTitle:nil];
    
}
-(void)test1234{
    
    _testCount = 0;
    __weak typeof(self) weakSelf = self;

    NSString *url2 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2010:20:07&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //阻力转换
    
//     NSString *url3 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:02:00&endtime=2021-01-10%2010:03:00&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //多时间
    
     NSString *url3 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2023:20:08&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //多时间
    
    [ETAFNetworking getLMK_AFNHttpSrt:url3 andTimeout:8.f andParam:nil success:^(id responseObject) {
        NSArray *series = responseObject[@"series"];
        if(series.count>2){
            weakSelf.testArray = series[1][@"data"];
            weakSelf.testArray2 = series[0][@"data"];

            
            NSLog(@"获取到的历史数据数量%ld  %@ %@ ",weakSelf.testArray.count,series[1][@"name"],series[1][@"data"]);
             self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testTimer56) userInfo:nil repeats:YES];
        }
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hideUIBlockingIndicator];
        });
    } WithHud:NO AndTitle:nil];
    
}
-(void)stopTest1234{
    [self.timer invalidate];
    self.timer = nil;
    _testCount = 0;
}
-(void)testTimer{
    if(DEVICETOOL.testStatus != TestStarted){
        NSLog(@"还未点击开始");
        return;
    }
    if(!DEVICETOOL.checkModel1){
        NSLog(@"生成DEVICETOOL.checkModel1");
        DEVICETOOL.checkModel1 = [[CheckModel alloc]init];
    }

    NSMutableArray *testArr = [NSMutableArray array];
    if(_testCount + 50 < self.testArray.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray[a];
            [testArr addObject:data[1]];
            [DEVICETOOL.deviceDataArr1 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray.count; a++) {
            NSArray *data = self.testArray[a];
            NSString *dataStr = data[1];
            long long dataLong = [dataStr longLongValue];
            NSNumber *num = [NSNumber numberWithLongLong:dataLong];
            [testArr addObject:num];
            [DEVICETOOL.deviceDataArr1 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    [self checkData:testArr withModel:DEVICETOOL.checkModel1 withTypeStr:@"J1" withId:1];
    _testCount = _testCount + 50;
    
}
-(void)testTimer56{
    if(DEVICETOOL.testStatus != TestStarted){
        NSLog(@"_Din 还未点击开始");
        return;
    }
    if(!DEVICETOOL.checkModel4){
        NSLog(@"_Din _Fab 生成DEVICETOOL.checkModel1");
        DEVICETOOL.checkModel4 = [[CheckModel alloc]init];
    }

    NSMutableArray *testArr = [NSMutableArray array];
    if(_testCount + 50 < self.testArray.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray[a];
            [testArr addObject:data[1]];
            [DEVICETOOL.deviceDataArr4 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray.count; a++) {
            NSArray *data = self.testArray[a];
            NSString *dataStr = data[1];
            long long dataLong = [dataStr longLongValue];
            NSNumber *num = [NSNumber numberWithLongLong:dataLong];
            [testArr addObject:num];
            [DEVICETOOL.deviceDataArr4 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    [self check56Data:testArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:11];
    
   

    NSMutableArray *testArr2 = [NSMutableArray array];
    if(_testCount + 50 < self.testArray2.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray2[a];
            [testArr2 addObject:data[1]];
            [DEVICETOOL.deviceDataArr5 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray2.count; a++) {
            NSArray *data = self.testArray2[a];
            NSString *dataStr = data[1];
            long long dataLong = [dataStr longLongValue];
            NSNumber *num = [NSNumber numberWithLongLong:dataLong];
            [testArr2 addObject:num];
            [DEVICETOOL.deviceDataArr5 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    [self check56Data:testArr2 withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:12];
    
    _testCount = _testCount + 50;
    
}
//检测56类型
-(void)check56Data:(NSArray <NSNumber*>*)dataArr withModel:(CheckModel*)model withTypeStr:(NSString*)typeStr withId:(NSInteger)id{
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
        dispatch_async(queue, ^{
            if(id == 11){
                if(dataArr.count > 10){
                        if(model.startValue == -10000){
                               long long sum = 0;
                               for(int i=0 ;i<5;i++){
                                    NSNumber *number = dataArr[i];  //调试修改
                                    sum += number.longValue;        //调试修
                               }
                               model.startValue = sum/5;
                               NSLog(@"_Din 前五个数据生成model.startValue = %ld",model.startValue);
                        }

                        long min = 100000;
                        long max = -100000;
                        long sun = 0;
                        for (NSNumber *number in dataArr) {
                            long num = number.longValue - model.startValue;
                            sun += num;
//                            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
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
                        
//                        NSLog(@"_Din mean = %ld min = %ld max=%ld",mean,min,max);
                        long meanSum = 0;
                        for (NSNumber *number in dataArr ) {
                            long num = number.longValue - model.startValue;
                            if((num - mean)>0){
                                meanSum += (num - mean);
                            }else{
                                meanSum += (mean - num);
                            }
                        }
                        long average = meanSum/(int)dataArr.count;
                        NSLog(@"_Din average = %ld",average);
                        if(average > 30){
                            if(average > 600){
//                                if(!model.closeDingChange2_OK){
//                                    //小变化没两秒就急速升高则是受阻空转后错误曲线
//                                    model.blockedError = YES;
//                                    if(mean > 0){
//                                        model.blockedErrorTypeUp = YES;
//                                    }
//                                     NSLog(@"_Din average > 400  model.blockedError = YES");
//                                }else{
                                    if(!model.blockedChange1_OK){
                                        model.blockedChange1_OK = YES;
                                        NSLog(@"_Din average > 600  model.blockedChange_OK = YES");
                                    }else{
                                        if(model.blockedStable2_OK){
                                            if(!model.blockedChange2_OK){
                                                model.blockedChange2_OK = YES;
                                                NSLog(@"_Din average > 600  model.blockedChange2_OK = YES");
                                            }
                                        }
                                    }
//                                }
                                
                            }
                            if(!model.closeDingChange2_OK && average > 100){
                                NSLog(@"_Din average > 100  model.closeDingChange2_OK = YES");
                                model.closeDingChange2_OK = YES;
                            }
                            if(!model.closeDingChange_OK){
                                NSLog(@"_Din average > 30  model.closeDingChange_OK = YES");
                                model.closeDingChange_OK = YES;
                            }
                            [model.dataArr addObjectsFromArray:dataArr];
                        }else{
                            if(mean  > 3500 || mean  < -3500){
                                [model.dataArr addObjectsFromArray:dataArr];
                                if(!model.blockedStable1_OK){
                                    model.blockedStable1_OK = YES;
                                    NSLog(@"_Din average < 30  model.blockedStable1_OK = YES");
                                }
                               else if(!model.blockedStable2_OK){
                                    model.blockedStable2_OK = YES;
                                    NSLog(@"_Din average < 30  model.blockedStable2_OK = YES");
                                }
                                else if(!model.blockedStable3_OK){
                                   
                                    model.blockedStable3_OK = YES;
                                }
                                //判断正反锁闭力 是否生成受阻锁闭力报告
                                if(!model.reportEdDing && model.blockedStable2_OK){
                                    model.reportEdDing = YES;
                                    model.reportBlockDing = YES;
                                    model.dataModel.station = DEVICETOOL.stationStr;
                                    model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                    model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                    model.dataModel.deviceType = typeStr;
                                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                    model.dataModel.timeLong = currentTime;
                                    model.dataModel.reportType = 5;
                                    
                                    if(mean < 0){
                                        model.dataModel.close_ding = model.startValue ;
                                        model.dataModel.keep_ding = model.startValue  + mean;
                                         NSLog(@"_Din mean  > 3500 定扳反受阻空转生成");
                                    }else{
                                        NSLog(@"_Din mean  > 3500 反扳定受阻空转生成");
                                        model.dataModel.close_ding = model.startValue + mean;
                                        model.dataModel.keep_ding = model.startValue;
                                    }
                                  }
                                 if(model.reportEdFan && model.reportEdDing && !model.reportEd){
                                     model.reportEd = YES;
                                     NSLog(@"_Din 锁闭力生成受阻锁闭力曲线报告 暂不清除model");
                                     [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
                                 }
                                 return;
                            }else{
                                if(model.closeDingChange2_OK){
                                    //波动结束
                                    NSDate *now = [NSDate date];
                                    NSTimeInterval nowInt = [now timeIntervalSince1970 ];
                                    model.endTime = nowInt;
                                    
//                                    if(model.blockedChange2_OK || model.blockedStable3_OK){
//                                        NSLog(@"受阻空转后恢复平稳值 清空掉model");
//                                        [self setCheckNilWith:id];
//                                        return;
//                                    }
                                    
                                    if(!model.blockedStable3_OK){
                                        
                                        if(! model.closeDingAfter1_OK){
                                            model.closeDingAfter1_OK = YES;
                                            NSLog(@"_Din model.closeDingAfter1_OK = YES");
                                        }else if( !model.closeDingAfter2_OK){
                                             model.closeDingAfter2_OK  = YES;
                                            NSLog(@"_Din model.closeDingAfter2_OK = YES");
                                        }else if( !model.closeDingAfter3_OK){
                                             model.closeDingAfter3_OK  = YES;
                                            NSLog(@"_Din model.closeDingAfter31_OK = YES");
                                        }
                                        if(model.dataArr.count < 50){
                                            if(model.closeDingChange_OK){
                                                NSLog(@"_Din 短波动 舍弃掉<50");
                                                [self setCheckNilWith:id];
                                            }
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
                                        
                                                            if(allMax - allMin > 3500 || allMax - allMin < -3500){
                                                                NSLog(@"_Din 检测到allMax - allMin > 2500 || allMax - allMin < -2500 舍弃掉");
                                                                [self setCheckNilWith:id];
                                                                return;
                                                            }
                                                                
                                                             if(!model.reportEdDing && model.closeDingAfter2_OK){
                                                        
                                                                model.reportEdDing = YES;
                                                                model.dataModel.station = DEVICETOOL.stationStr;
                                                                model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                                                model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                                                model.dataModel.deviceType = typeStr;
                                                                long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                                                model.dataModel.timeLong = currentTime;
                                                                model.dataModel.reportType = 5;
                                                                
                                                                if(mean < 0){
                                                                    model.dataModel.close_ding = model.startValue ;
                                                                    model.dataModel.keep_ding = model.startValue + mean;
                                                                     NSLog(@"_Din  正常定扳反锁闭力生成");
                                                                }else{
                                                                    NSLog(@"_Din  反扳定扳定锁闭生成");
                                                                    model.dataModel.close_ding = model.startValue + mean;
                                                                    model.dataModel.keep_ding = model.startValue;
                                                                }
                                                              }
                                                             if(model.reportEdFan && model.reportEdDing && !model.reportEd){
                                                                 model.reportEd = YES;
                                                                 [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
                                                                 NSLog(@"_Din 正常锁闭力曲线报告 ");
                                                                 if(!model.reportBlockFan){
                                                                     NSLog(@"_Din 正常锁闭力曲线报告 且清除model");
                                                                     [self setCheckNilWith:id];
                                                                 }
                                                                 return;
                                                             }
                                        
                                    }else{
                                        NSLog(@"_Din 受阻曲线结束 且清除model");
                                        [self setCheckNilWith:id];
                                        return;
                                    }
                                }else{
//                                    if(model.closeDingChange_OK){
//                                        NSLog(@"_Din 小波动 舍弃掉");
//                                        [self setCheckNilWith:id];
//                                    }
//                                    return;
                                }
                            }
                            if(!model.closeDingChange_OK){
                                NSLog(@"_Din 检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
                                model.startValue = mean + model.startValue;
                            }
                        }
                    }
            }else{
                if(dataArr.count > 10){
                        if(model.startValue_Fan == -10000){
                               long long sum = 0;
                               for(int i=0 ;i<5;i++){
                                    NSNumber *number = dataArr[i];  //调试修改
                                    sum += number.longValue;        //调试修
                               }
                               model.startValue_Fan = sum/5;
                               NSLog(@"_Fan 前五个数据生成model.startValue = %ld",model.startValue_Fan);
                        }

                        long min = 100000;
                        long max = -100000;
                        long sun = 0;
                        for (NSNumber *number in dataArr) {
                            long num = number.longValue - model.startValue_Fan;
                            sun += num;
                //            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
                            if(num < min){
                                min = num;
                            }
                            if(num > max){
                                max = num;
                            }
                        }
                        if(min < model.min_Fan){
                            model.min_Fan = min;
                        }
                        if(max > model.max_Fan){
                            model.max_Fan = max;
                        }
                        
                        long mean = sun/(int)dataArr.count;
                        
                        NSLog(@"_Fan mean = %ld min = %ld max=%ld",mean,min,max);
                        long meanSum = 0;
                        for (NSNumber *number in dataArr ) {
                            long num = number.longValue - model.startValue_Fan;
                            if((num - mean)>0){
                                meanSum += (num - mean);
                            }else{
                                meanSum += (mean - num);
                            }
                        }
                        long average = meanSum/(int)dataArr.count;
                        NSLog(@"_Fan average = %ld",average);
                        if(average > 30){
                            if(average > 600){
//                                if(!model.closeFanChange2_OK){
//                                    //小变化没两秒就急速升高则是受阻空转后错误曲线
//                                    model.blockedError_Fan = YES;
//                                    if(mean > 0){
//                                        model.blockedErrorTypeUp_Fan = YES;
//                                    }
//                                     NSLog(@"_Fan average > 400  model.blockedError = YES");
//                                }else{
                                    if(!model.blockedChange1_OK_Fan){
                                        model.blockedChange1_OK_Fan = YES;
                                        NSLog(@"_Fan average > 400  model.blockedChange_OK = YES");
                                    }else{
                                        if(model.blockedStable2_OK_Fan){
                                            model.blockedChange2_OK_Fan = YES;
                                             NSLog(@"_Fan average > 400  model.blockedChange2_OK = YES");
                                        }
                                    }
//                                }
                                
                            }
                            if(!model.closeFanChange2_OK &&  average > 100){
                                model.closeFanChange2_OK = YES;
                            }
                            else{
                                
                            }
                            if(!model.closeFanChange_OK){
                                NSLog(@"_Fan average > 400  model.closeFanChange_OK = YES");
                                model.closeFanChange_OK = YES;
                            }
                            [model.dataArr_Fan addObjectsFromArray:dataArr];
                        }else{
                            if(mean  > 3500 || mean  < -3500){
                                [model.dataArr_Fan addObjectsFromArray:dataArr];
                                if(!model.blockedStable1_OK_Fan){
                                    model.blockedStable1_OK_Fan = YES;
                                    NSLog(@"_Fan average < 70  model.blockedStable1_OK = YES");
                                }
                                else if(!model.blockedStable2_OK_Fan){
                                    model.blockedStable2_OK_Fan = YES;
                                    NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES");
                                }
                                else if(!model.blockedStable3_OK_Fan){
                                   
                                    model.blockedStable3_OK_Fan = YES;
                                }
                                //判断正反锁闭力 是否生成受阻锁闭力报告
                                if(!model.reportEdFan && model.blockedStable2_OK_Fan){
                                    model.reportEdFan = YES;
                                    model.reportBlockFan = YES;
                                    model.dataModel.station = DEVICETOOL.stationStr;
                                    model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                    model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                    model.dataModel.deviceType = typeStr;
                                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                    model.dataModel.timeLong = currentTime;
                                    model.dataModel.reportType = 5;
                                    
                                    if(mean < 0){
                                        model.dataModel.close_fan = model.startValue_Fan ;
                                        model.dataModel.keep_fan = model.startValue_Fan  + mean;
                                         NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
                                    }else{
                                        NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES 反扳定受阻空转生成");
                                        model.dataModel.close_fan = model.startValue_Fan + mean;
                                        model.dataModel.keep_fan = model.startValue_Fan;
                                    }
                                  }
                                 if(model.reportEdFan && model.reportEdDing && !model.reportEd){
                                     model.reportEd = YES;
                                     NSLog(@"_Fan 锁闭力生成受阻锁闭力曲线报告 暂不清除model");
                                     [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
                                 }
                                 return;
                            }else{
                                if(model.closeFanChange2_OK){
                                    //波动结束
                                    NSDate *now = [NSDate date];
                                    NSTimeInterval nowInt = [now timeIntervalSince1970 ];
                                    model.endTime = nowInt;
                                    
                                    if(model.blockedChange2_OK_Fan || model.blockedStable3_OK_Fan){
                                        NSLog(@"_Fan 受阻空转后恢复平稳值 清空掉model");
                                        [self setCheckNilWith:id];
                                        return;
                                    }
                                    
                                    if(!model.blockedStable3_OK_Fan){
                                        
                                        if(! model.closeFanAfter1_OK){
                                            model.closeFanAfter1_OK = YES;
                                        }else if(! model.closeFanAfter2_OK){
                                             model.closeFanAfter2_OK  = YES;
                                        }else if(! model.closeFanAfter3_OK){
                                             model.closeFanAfter3_OK  = YES;
                                        }
                                        if(model.dataArr_Fan.count < 50){
                                            if(model.closeFanChange_OK){
                                                NSLog(@"_Fan 短波动 舍弃掉");
                                                [self setCheckNilWith:id];
                                            }
                                            return;
                                        }
                                                            long allMin = 100000;
                                                            long allMax = -100000;
                                                            long allSun = 0;
                                                            for (NSNumber *number in model.dataArr_Fan) {
                                                                long num = number.longValue ;
                                                                allSun += num;
                                                                if(num < allMin){
                                                                    allMin = num;
                                                                }
                                                                if(num > allMax){
                                                                    allMax = num;
                                                                }
                                                            }
                                        
                                                            if(allMax - allMin > 3500 || allMax - allMin < -3500){
                                                                NSLog(@"_Fan 检测到allMax - allMin > 2500 || allMax - allMin < -2500 舍弃掉");
                                                                [self setCheckNilWith:id];
                                                                return;
                                                            }
                                                                
                                                             if(!model.reportEdFan && model.closeFanAfter2_OK){
                                                        
                                                                model.reportEdFan = YES;
                                                                model.dataModel.station = DEVICETOOL.stationStr;
                                                                model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                                                model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                                                model.dataModel.deviceType = typeStr;
                                                                long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                                                model.dataModel.timeLong = currentTime;
                                                                model.dataModel.reportType = 5;
                                                                
                                                                if(mean < 0){
                                                                    model.dataModel.close_fan = model.startValue_Fan ;
                                                                    model.dataModel.keep_fan = model.startValue_Fan + mean;
                                                                     NSLog(@"_Fan 正常定扳反锁闭力生成");
                                                                }else{
                                                                    NSLog(@" _Fan 正常反扳定锁闭生成");
                                                                    model.dataModel.close_fan = model.startValue_Fan + mean;
                                                                    model.dataModel.keep_fan = model.startValue_Fan;
                                                                }
                                                              }
                                                             if(model.reportEdFan && model.reportEdDing && !model.reportEd){
                                                                 model.reportEd = YES;
                                                                 [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
                                                                 NSLog(@"_Fan 正常锁闭力曲线报告 ");
                                                                 if(!model.reportBlockDing){
                                                                     NSLog(@"_Fan 正常锁闭力曲线报告 且清除model");
                                                                     [self setCheckNilWith:id];
                                                                 }
                                                                 return;
                                                             }
                                        
                                    }else{
                                        NSLog(@"_Fan 受阻曲线结束 且清除model");
                                        [self setCheckNilWith:id];
                                        return;
                                    }
                                }else{
//                                    if(model.closeFanChange_OK){
//                                        NSLog(@"_Fan小波动 舍弃掉");
//                                        [self setCheckNilWith:id];
//                                    }
//                                    return;
                                }
                            }
                            if(!model.closeFanChange_OK){
                                NSLog(@"_Fan 检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
                                model.startValue_Fan = mean + model.startValue_Fan;
                            }
                        }
                    }
            }
        });
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
                        if(DEVICETOOL.shenSuo == Shen_Ding){
                              dataModel.reportType = 2;
                        }else if(DEVICETOOL.shenSuo == Shen_Fan){
                              dataModel.reportType = 4;
                        }
                        dataModel.blocked_Top = model.min + model.startValue;
                         NSLog(@"average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
                    }else{
                         model.blocked_max = max;
                       if(DEVICETOOL.shenSuo == Shen_Ding){
                              dataModel.reportType = 4;
                        }else if(DEVICETOOL.shenSuo == Shen_Fan){
                              dataModel.reportType = 2;
                        }
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
                                               if(DEVICETOOL.shenSuo == Shen_Ding){
                                                     dataModel.reportType = 1;
                                               }else if(DEVICETOOL.shenSuo == Shen_Fan){
                                                     dataModel.reportType = 3;
                                               }
                                               dataModel.all_Top = model.min + model.startValue;
                                               dataModel.all_mean = allMean;
                                               
                                               dataModel.open_Top = openMin;
                                               dataModel.open_mean = openMean;
                                               
                                               dataModel.transform_Top = transformMin;
                                               dataModel.transform_mean = transformMean;
                                               
                                               dataModel.close_Top = closeMin;
                                               dataModel.close_mean = closeMean;
                                               NSLog(@" 扳动类型%ld halfMean= %ld  model.startValue= %ld",dataModel.reportType, halfMean,model.startValue);
                                           }else{
                                               if(DEVICETOOL.shenSuo == Shen_Ding){
                                                      dataModel.reportType = 3;
                                               }else if(DEVICETOOL.shenSuo == Shen_Fan){
                                                     dataModel.reportType = 1;
                                               }
                                               dataModel.all_Top = model.max + model.startValue;
                                               dataModel.all_mean = allMean;
                                               
                                               dataModel.open_Top = openMax;
                                               dataModel.open_mean = openMean;
                                               
                                               dataModel.transform_Top = transformMax;
                                               dataModel.transform_mean = transformMean;
                                               
                                               dataModel.close_Top = closeMax;
                                               dataModel.close_mean = closeMean;
                                               NSLog(@" 扳动类型%ld halfMean= %ld  model.startValue= %ld",dataModel.reportType, halfMean,model.startValue);
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
                model.startValue = mean + model.startValue;
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
                           DEVICETOOL.checkModel4 = nil;
                       }
}
-(void)changeDevice:(NSDictionary *)dic{
            DeviceTool *delegate = [DeviceTool shareInstance];
            BOOL isExit = NO;
            for(int a = 0;a<delegate.deviceArr.count;a++){
                Device *device = delegate.deviceArr[a];
                if([device.id isEqualToString:dic[@"id"]]){
                    isExit = YES;
                    break;
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
                        newDevice.typeStr = @"定位锁闭锁力";
                        break;
                    case 12:
                        newDevice.typeStr = @"反位锁闭力";
                        break;
                    default:
                        break;
                }
                [delegate.deviceArr addObject:newDevice];
                [delegate.deviceArr sortedArrayUsingComparator:^(Device *obj1,Device*obj2){
                               if([obj1.id integerValue] < [obj2.id integerValue]){
                                   return NSOrderedAscending;
                               }else{
                                   return NSOrderedAscending;
                               }
                }];
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

