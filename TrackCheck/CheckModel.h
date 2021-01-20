//
//  CheckModel.h
//  TrackCheck
//
//  Created by ethome on 2021/1/18.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckModel : NSObject

@property (nonatomic,assign)long  startTime;
@property (nonatomic,assign)long  endTime;
@property (nonatomic,assign)long  startValue;

@property (nonatomic,assign)long  max;
@property (nonatomic,assign)long  min;

@property (nonatomic,strong)NSMutableArray* dataArr;

@property (nonatomic,assign)BOOL  step1_OK;
@property (nonatomic,assign)long  step1_mean;
@property (nonatomic,assign)long  step1_max;
@property (nonatomic,assign)long  step1_min;
@property (nonatomic,assign)long  step1_average;

@property (nonatomic,assign)BOOL  step2_OK;
@property (nonatomic,assign)long  step2_mean;
@property (nonatomic,assign)long  step2_max;
@property (nonatomic,assign)long  step2_min;
@property (nonatomic,assign)long  step2_average;

@property (nonatomic,assign)BOOL  step3_OK;
@property (nonatomic,assign)long  step3_mean;
@property (nonatomic,assign)long  step3_max;
@property (nonatomic,assign)long  step3_min;
@property (nonatomic,assign)long  step3_average;

@property (nonatomic,assign)BOOL  step4_OK;
@property (nonatomic,assign)long  step4_mean;
@property (nonatomic,assign)long  step4_max;
@property (nonatomic,assign)long  step4_min;
@property (nonatomic,assign)long  step4_average;

@property (nonatomic,assign)BOOL  blockedChange_OK;
@property (nonatomic,assign)BOOL  blockedStable1_OK;
@property (nonatomic,assign)BOOL  blockedStable2_OK;

@property (nonatomic,assign)long blockedStable_value;
@property (nonatomic,assign)long blocked_max;

@property (nonatomic,assign)BOOL  close1_OK;
@property (nonatomic,assign)BOOL  closeChange_OK;
@property (nonatomic,assign)BOOL  closeStable1_OK;
@property (nonatomic,assign)BOOL  closeStable2_OK;

@property (nonatomic,assign)long closeValue;//闭锁力
@property (nonatomic,assign)long stableValue;//保持力
@end

NS_ASSUME_NONNULL_END
