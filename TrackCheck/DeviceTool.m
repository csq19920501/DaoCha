//
//  DeviceTool.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "DeviceTool.h"

@implementation DeviceTool
+ (DeviceTool *)shareInstance{
    
    static DeviceTool *tcpSocket =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tcpSocket = [[DeviceTool alloc] init];
        tcpSocket.deviceNameArr = @[@"J1",@"J2",@"J3",@"X1",@"X2"];
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
        NSLog(@"userdefault 获取stationStr = %@",tcpSocket.stationStr);
        tcpSocket.roadSwitchNo = [user objectForKey:@"roadSwitchNo"];
        
        NSArray *stationStrArr = [user objectForKey:@"stationStrArr"];
        NSLog(@"userdefault 获取stationStrArr = %@",stationStrArr);
        if(stationStrArr.count == 0){
            stationStrArr = @[@"杭州南站",@"杭州基地",@"杭州站",@"杭州南站2"];
        }
        tcpSocket.stationStrArr = [NSMutableArray arrayWithArray:stationStrArr];
        
        
//        NSArray *roadSwitchNoArr = [user objectForKey:@"roadSwitchNoArr"];
//        NSLog(@"userdefault 获取roadSwitchNoArr = %@",roadSwitchNoArr);
        tcpSocket.roadSwitchNoArr = [NSMutableArray arrayWithArray:[user objectForKey:@"roadSwitchNoArr"]];
        tcpSocket.saveStaionTime = [[user objectForKey:@"saveStaionTime"] longLongValue];
    });
    return tcpSocket;
}
//-(void)setStationStr:(NSString *)stationStr{
//    _stationStr = stationStr;
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    [user setObject:stationStr forKey:@"stationStr"];
//
//    long long currentTime = [[NSDate date] timeIntervalSince1970];
//    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
//    [user setObject:time forKey:@"saveStaionTime"];
//    NSLog(@"userdefault保存 stationStr = %@",stationStr);
//}
//-(void)setStationStrArr:(NSMutableArray *)stationStrArr{
//    _stationStrArr = stationStrArr;
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    [user setObject:[NSArray arrayWithArray:_stationStrArr] forKey:@"stationStrArr"];
//}
//-(void)setRoadSwitchNoArr:(NSMutableArray *)roadSwitchNoArr{
//    _roadSwitchNoArr = roadSwitchNoArr;
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    [user setObject:_roadSwitchNoArr forKey:@"roadSwitchNoArr"];
//}
//-(void)setRroadSwitchNo:(NSString *)roadSwitchNo{
//    _roadSwitchNo = roadSwitchNo;
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    [user setObject:roadSwitchNo forKey:@"roadSwitchNo"];
//
//    long long currentTime = [[NSDate date] timeIntervalSince1970];
//    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
//    [user setObject:time forKey:@"saveStaionTime"];
//}
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
@end
