//
//  DeviceTool.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "DeviceTool.h"
#import "TestDataModel.h"
@implementation DeviceTool
+ (DeviceTool *)shareInstance{
    
    static DeviceTool *tcpSocket =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tcpSocket = [[DeviceTool alloc] init];
        tcpSocket.isDebug = NO;
        tcpSocket.seleLook = ONE;
        tcpSocket.shenSuo = NoSet;
        tcpSocket.jOrX = J;
        tcpSocket.deviceNameArr = @[@"J1",@"J2",@"J3",@"J4",@"J5",@"J6"];
        tcpSocket.deviceArr = [NSMutableArray array];
        tcpSocket.deviceDataArr1 = [NSMutableArray array];
        tcpSocket.deviceDataArr2 = [NSMutableArray array];
        tcpSocket.deviceDataArr3 = [NSMutableArray array];
        tcpSocket.deviceDataArr4 = [NSMutableArray array];
        tcpSocket.deviceDataArr5 = [NSMutableArray array];
        
        tcpSocket.stationStrArr = [NSMutableArray array];
        tcpSocket.roadSwitchNoArr = [NSMutableArray array];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        tcpSocket.stationStr = [user objectForKey:@"stationStr"];
        tcpSocket.roadSwitchNo = [user objectForKey:@"roadSwitchNo"];
        NSArray *stationStrArr = [user objectForKey:@"stationStrArr"];
        if(stationStrArr.count == 0){
            stationStrArr = @[@"杭州南站",@"杭州基地",@"杭州站",@"杭州南站2"];
        }
        tcpSocket.stationStrArr = [NSMutableArray arrayWithArray:stationStrArr];
        tcpSocket.roadSwitchNoArr = [NSMutableArray arrayWithArray:[user objectForKey:@"roadSwitchNoArr"]];
        tcpSocket.saveStaionTime = [[user objectForKey:@"saveStaionTime"] longLongValue];
    });
    return tcpSocket;
}
-(void)removeAllData{
    [self.deviceDataArr1 removeAllObjects];
    [self.deviceDataArr2 removeAllObjects];
    [self.deviceDataArr3 removeAllObjects];
    [self.deviceDataArr4 removeAllObjects];
    [self.deviceDataArr5 removeAllObjects];
    self.checkModel1 = nil;
    self.checkModel2 = nil;
    self.checkModel3 = nil;
    self.checkModel4 = nil;
    self.checkModel5 = nil;
}
-(void)syncArr{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSArray arrayWithArray:_stationStrArr] forKey:@"stationStrArr"];
    [user setObject:[NSArray arrayWithArray:_roadSwitchNoArr] forKey:@"roadSwitchNoArr"];
    NSLog(@"userdefault 保存 _roadSwitchNoArr = %@",_roadSwitchNoArr);
    [user setObject:_stationStr forKey:@"stationStr"];
    [user setObject:_roadSwitchNo forKey:@"roadSwitchNo"];
    long long currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
    [user setObject:time forKey:@"saveStaionTime"];
    [user synchronize];
   
}
-(void)getSavedStationArr{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        NSMutableArray *arr = [NSMutableArray array];
        NSArray <TestDataModel *> * results = [[LPDBManager defaultManager] findModels: [TestDataModel class]
         where:nil];
        for (TestDataModel *model in results) {
            NSArray*statArr = [NSArray arrayWithArray:arr];
            BOOL isExit = NO;
            for(NSString *str  in statArr){
                if([str isEqualToString:model.station]){
                    isExit = YES;
                    break;
                }
            }
            if(!isExit){
                [arr addObject:model.station];
            }
        }
        self.savedStationArr = [NSArray arrayWithArray:arr];
    });
}
@end
