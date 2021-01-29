//
//  ReportModel.h
//  TrackCheck
//
//  Created by ethome on 2021/1/18.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDB.h"
NS_ASSUME_NONNULL_BEGIN

@interface ReportModel : LPDBModel

//@property (nonatomic,strong)NSString *keyStr;
@property (nonatomic,strong)NSString *idStr;
@property (nonatomic,strong)NSString *station;
@property (nonatomic,strong)NSString *roadSwitch;
@property (nonatomic,strong)NSString *deviceType;
@property (nonatomic,assign)long long timeLong ;
@property (nonatomic,strong)NSString * timeLongStr ;
//事件类型  1 定扳反 2定扳反受阻 3反扳定 4反扳定受阻空转 5锁闭力定扳反  6锁闭力定扳反受阻  7闭锁力反扳定  8闭锁力反扳定受阻
@property (nonatomic,assign)NSInteger reportType;

@property (nonatomic,assign)NSInteger open_Top;
@property (nonatomic,assign)NSInteger open_mean;

@property (nonatomic,assign)NSInteger transform_Top;
@property (nonatomic,assign)NSInteger transform_mean;

@property (nonatomic,assign)NSInteger close_Top;
@property (nonatomic,assign)NSInteger close_mean;

@property (nonatomic,assign)NSInteger all_Top;
@property (nonatomic,assign)NSInteger all_mean;

@property (nonatomic,assign)NSInteger blocked_Top;
@property (nonatomic,assign)NSInteger blocked_stable;

@property (nonatomic,assign)NSInteger close_ding;  //
@property (nonatomic,assign)NSInteger close_fan;

@property (nonatomic,assign)NSInteger keep_ding;
@property (nonatomic,assign)NSInteger keep_fan;

@end

NS_ASSUME_NONNULL_END
