//
//  TestDataModel.h
//  TrackCheck
//
//  Created by ethome on 2021/1/14.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDB.h"
NS_ASSUME_NONNULL_BEGIN

@interface TestDataModel : LPDBModel

@property (nonatomic,strong)NSString *station;
@property (nonatomic,strong)NSString *roadSwitch;
@property (nonatomic,strong)NSString *deviceType;
@property (nonatomic,strong)NSString *idStr;
//@property (nonatomic,strong)NSNumber *time;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,assign)long long timeLong ;

@property (nonatomic,strong)NSMutableArray * reportArr;

@property (nonatomic,strong)NSMutableArray *colorArr;
@property (nonatomic,strong)NSMutableArray *fanColorArr;
@property (nonatomic,strong)NSMutableArray *close_transArr;//锁闭力测试时对应的转换阻力 报告区间
@end

NS_ASSUME_NONNULL_END
