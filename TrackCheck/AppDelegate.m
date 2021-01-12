//
//  AppDelegate.m
//  TrackCheck
//
//  Created by ethome on 2021/1/6.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "AppDelegate.h"
#import "CSQScoketService.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    self.deviceArr = [NSMutableArray array];
    
//    [DeviceTool shareInstance].stationStr = @"杭州南站";
//    [DeviceTool shareInstance].roadSwitchNo = @"109道岔";

    self.scoketThread = [[NSThread alloc]initWithTarget:self selector:@selector(startSocket) object:nil];
    [self.scoketThread start];
    
    return YES;
}
-(void)startSocket{
    CSQScoketService *socketSerview = [[CSQScoketService alloc]init];
               //开始服务
    [socketSerview start];
               
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]run];//目的让服务器不停止//循环运行
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
