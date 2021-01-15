//
//  DeviceTool.h
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum:NSInteger{
    TestNotStart,
    TestStarted,
    TestEnd,
}CSQTestStatus;
typedef enum:NSInteger{
    J,
    X,
}CSQJOrX;
typedef enum:NSInteger{
    ONE,
    TWO,
}CSQSeleLook;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceTool : NSObject
+(DeviceTool*)shareInstance;
@property(nonatomic,strong)NSMutableArray *deviceArr;
@property(nonatomic,copy)NSString *roadSwitchNo;
@property(nonatomic,strong)NSMutableArray *roadSwitchNoArr;
@property(nonatomic,copy)NSString *stationStr;
@property(nonatomic,strong)NSMutableArray *stationStrArr;
@property(nonatomic,assign)long long saveStaionTime;
@property(nonatomic,strong)NSMutableArray *deviceDataArr1;
@property(nonatomic,strong)NSMutableArray *deviceDataArr2;
@property(nonatomic,strong)NSMutableArray *deviceDataArr3;
@property(nonatomic,strong)NSMutableArray *deviceDataArr4;
@property(nonatomic,strong)NSMutableArray *deviceDataArr5;
@property(nonatomic,strong)NSArray *deviceNameArr;
@property (nonatomic,assign)CSQTestStatus testStatus;
@property (nonatomic,assign)CSQSeleLook seleLook;
@property (nonatomic,assign)CSQJOrX jOrX;
-(void)syncArr;
-(void)removeAllData;
@end

NS_ASSUME_NONNULL_END
