//
//  DeviceTool.h
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckModel.h"
#import "Device.h"
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
typedef enum:NSInteger{
    NoSet,
    Shen_Ding,
    Shen_Fan,
}CSQShenSuo;
NS_ASSUME_NONNULL_BEGIN

@interface DeviceTool : NSObject
+(DeviceTool*)shareInstance;
@property(nonatomic,strong)NSMutableArray *deviceArr;
@property(nonatomic,copy)NSString *roadSwitchNo;
@property(nonatomic,strong)NSMutableArray *roadSwitchNoArr;
@property(nonatomic,copy)NSString *stationStr;
@property(nonatomic,copy)NSString *closeLinkDevice;
@property(nonatomic,strong)NSMutableArray *stationStrArr;
@property(nonatomic,assign)long long saveStaionTime;
@property(nonatomic,assign)long long startTime;
@property(nonatomic,strong)NSMutableArray *deviceDataArr1;
@property(nonatomic,strong)NSMutableArray *deviceDataArr2;
@property(nonatomic,strong)NSMutableArray *deviceDataArr3;
@property(nonatomic,strong)NSMutableArray *deviceDataArr4;
@property(nonatomic,strong)NSMutableArray *deviceDataArr5;
@property(nonatomic,strong)NSArray *deviceNameArr;
@property (nonatomic,assign)CSQTestStatus testStatus;
@property (nonatomic,assign)CSQSeleLook seleLook;
@property (nonatomic,assign)CSQJOrX jOrX;
@property (nonatomic,assign)CSQShenSuo shenSuo;
@property(nonatomic,strong)NSArray *savedStationArr;
@property(nonatomic,strong,nullable)CheckModel*checkModel1;
@property(nonatomic,strong,nullable)CheckModel*checkModel2;
@property(nonatomic,strong,nullable)CheckModel*checkModel3;
@property(nonatomic,strong,nullable)CheckModel*checkModel4;
@property(nonatomic,strong,nullable)CheckModel*checkModel5;

@property (nonatomic,assign)BOOL  isDebug;
@property (nonatomic,assign)BOOL  isX3;
-(void)syncArr;
-(void)removeAllData;
-(void)getSavedStationArr;

-(void)changeReport:(PYOption *)option reportArr:(NSArray*)device maxCount:(int)maxCount;
@end

NS_ASSUME_NONNULL_END
