//
//  ReportModel.m
//  TrackCheck
//
//  Created by ethome on 2021/1/18.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "ReportModel.h"

@implementation ReportModel

+ (NSString *)primaryKey
{
    return @"timeLongStr";
}
//@property (nonatomic,strong)NSString *idStr;
//@property (nonatomic,strong)NSString *station;
//@property (nonatomic,strong)NSString *roadSwitch;
//@property (nonatomic,strong)NSString *deviceType;
//@property (nonatomic,assign)long long timeLong ;
//@property (nonatomic,strong)NSString * timeLongStr ;
//@property (nonatomic,assign)NSInteger close_ding;  //
//@property (nonatomic,assign)NSInteger close_fan;
//
//@property (nonatomic,assign)NSInteger keep_ding;
//@property (nonatomic,assign)NSInteger keep_fan;
+(ReportModel *)initWithReport:(ReportModel *)model{
    ReportModel *report = [[ReportModel alloc]init];
    report.idStr = model.idStr;
    report.station = model.station;
    report.roadSwitch = model.roadSwitch;
    report.deviceType = model.deviceType;
    report.timeLong = model.timeLong;
    report.timeLongStr = model.timeLongStr;
    report.close_ding = model.close_ding;
    
    report.close_fan = model.close_fan;
    
    report.keep_ding = model.keep_ding;
    
    report.keep_fan = model.keep_fan;
    report.reportType = model.reportType;
    return report;
}
@end
