//
//  CheckModel.h
//  TrackCheck
//
//  Created by ethome on 2021/1/18.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CheckModel : NSObject

@property (nonatomic,assign)long  startTime;
@property (nonatomic,assign)long  startTime_Fan;
@property (nonatomic,assign)long  endTime;
@property (nonatomic,assign)long  startValue;
@property (nonatomic,assign)long  startValue_Fan;

@property (nonatomic,assign)long  max;
@property (nonatomic,assign)long  max_Fan;
@property (nonatomic,assign)long  min;
@property (nonatomic,assign)long  min_Fan;

@property (nonatomic,strong)NSMutableArray* dataArr; //只包含力大小
@property (nonatomic,strong)NSMutableArray* timeArr; //只包含时间值
@property (nonatomic,strong)NSMutableArray* fanTimeArr; //只包含时间值
@property (nonatomic,strong)NSMutableArray* dataBlockArr;
@property (nonatomic,strong)NSMutableArray* dataArr_Fan;

@property (nonatomic,assign)BOOL  step1_OK;
@property (nonatomic,assign)long  step1_mean;
@property (nonatomic,assign)long  step1_max;
@property (nonatomic,assign)long  step1_min;
@property (nonatomic,assign)long  step1_average;

@property (nonatomic,assign)BOOL  stable_1;
@property (nonatomic,assign)BOOL  stable_2;
@property (nonatomic,assign)BOOL  stable_3;

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

@property (nonatomic,assign)BOOL  blockedChange1_OK;  //受阻上升
@property (nonatomic,assign)BOOL  blockedChange2_OK;  //受阻下降

@property (nonatomic,assign)BOOL  blockedStable1_OK;    //受阻稳定
@property (nonatomic,assign)BOOL  blockedStable2_OK;
@property (nonatomic,assign)BOOL  blockedStable3_OK;
@property (nonatomic,assign)BOOL  blockedStable4_OK;
@property (nonatomic,assign)BOOL  blockedStable5_OK;


@property (nonatomic,assign)BOOL  blockedChange1_OK_Fan;  //受阻上升
@property (nonatomic,assign)BOOL  blockedChange2_OK_Fan;  //受阻下降

@property (nonatomic,assign)BOOL  blockedStable1_OK_Fan;    //受阻稳定
@property (nonatomic,assign)BOOL  blockedStable2_OK_Fan;
@property (nonatomic,assign)BOOL  blockedStable3_OK_Fan;

@property (nonatomic,assign)long blockedStable_value;
@property (nonatomic,assign)long blocked_max;

@property (nonatomic,assign)BOOL  blockedError;
@property (nonatomic,assign)BOOL  blockedErrorTypeUp;

@property (nonatomic,assign)BOOL  blockedError_Fan;
@property (nonatomic,assign)BOOL  blockedErrorTypeUp_Fan;

//@property (nonatomic,assign)BOOL  close1_OK;
//@property (nonatomic,assign)BOOL  closeChange_OK;
//@property (nonatomic,assign)BOOL  closeStable1_OK;
//@property (nonatomic,assign)BOOL  closeStable2_OK;
//@property (nonatomic,assign)long closeValue;//闭锁力
//@property (nonatomic,assign)long stableValue;//保持力



@property (nonatomic,assign)BOOL  closeDingBefore_OK;
@property (nonatomic,assign)BOOL  closeDingChange_OK;
@property (nonatomic,assign)BOOL  closeDingChange2_OK;

@property (nonatomic,assign)BOOL  closeDingAfter1_OK;
@property (nonatomic,assign)BOOL  closeDingAfter2_OK;
@property (nonatomic,assign)BOOL  closeDingAfter3_OK;

@property (nonatomic,assign)long  closeDingBeforeValue;//闭锁力
@property (nonatomic,assign)long  closeDingAfterValue;//保持力


@property (nonatomic,assign)BOOL  closeFanBefore_OK;
@property (nonatomic,assign)BOOL  closeFanChange_OK;
@property (nonatomic,assign)BOOL  closeFanChange2_OK;
@property (nonatomic,assign)BOOL  closeFanAfter1_OK;
@property (nonatomic,assign)BOOL  closeFanAfter2_OK;
@property (nonatomic,assign)BOOL  closeFanAfter3_OK;
@property (nonatomic,assign)long  closeFanBeforeValue;//闭锁力
@property (nonatomic,assign)long  closeFanAfterValue;//保持力

@property (nonatomic,assign)BOOL  reportEdDing;
@property (nonatomic,assign)BOOL  reportEdFan;

@property (nonatomic,assign)BOOL  reportEd;

@property (nonatomic,assign)BOOL  reportBlockDing;
@property (nonatomic,assign)BOOL  reportBlockFan;

@property (nonatomic,strong)ReportModel *dataModel;
@end

NS_ASSUME_NONNULL_END
