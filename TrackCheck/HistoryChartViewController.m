//
//  HistoryChartViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/15.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "HistoryChartViewController.h"
#import "ReportModel.h"
@interface HistoryChartViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *chartView;
@property(nonatomic ,strong)NSArray *results;

@end

@implementation HistoryChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _addressLabel.text = [NSString stringWithFormat:@"地点:%@%@",_dataModel.station,_dataModel.roadSwitch];
    _deviceTypeLabel.text = [NSString stringWithFormat:@"牵引点:%@",_dataModel.deviceType];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:_dataModel.timeLong];
        NSString *time = [dateFormatter stringFromDate:date];
        _timeLabel.text = time;
    NSString *type = _dataModel.deviceType;
    if(![type containsString:@"锁闭力"]){
           [_chartView setOption:[self getOption]];
    }else{
        [_chartView setOption:[self getOption2]];
    }
    [_chartView loadEcharts];
    
    _results = [[LPDBManager defaultManager] findModels: [ReportModel class]
    where: @"idStr = '%@'",_dataModel.idStr];
    if(![type containsString:@"锁闭力"]){
           [_chartView refreshEchartsWithOption:[self getOption]];
    }else{
        [_chartView refreshEchartsWithOption:[self getOption2]];
    }
}
- (PYOption *)getOption {
   
    NSMutableArray *saveDataArr;
//    NSMutableArray *saveDataArr2;
    saveDataArr = [NSMutableArray arrayWithArray:_dataModel.dataArr];
    if(saveDataArr.count == 0){
    long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
    NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
    saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }

    NSString *titleStr = [NSString stringWithFormat:@"%@%@",_dataModel.deviceType,@"曲线图"];

    PYOption *option =  [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
            .subtextEqual(@"");
        }])
        .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@40).x2Equal(@40).y2Equal(@80).yEqual(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
//            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
        }])
        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[titleStr]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@8)
            .scaleEqual(YES)
            .splitLineEqual([PYAxisSplitLine initPYAxisSplitLineWithBlock:^(PYAxisSplitLine *splitLine) {
                splitLine.showEqual(NO);
            }])
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}:${ss}`;})");
                
            }]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue).scaleEqual(YES).boundaryGapEqual(@[@"2.5%",@"2.5%"]);
//            .minEqual(@(-1000))
//            .maxEqual(@(4000));
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
        series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(titleStr).typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(@"average");
        }]);
//        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
//        series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"反位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr2);
//        }]);
    }];
    [DEVICETOOL changeReport:option reportArr:_results maxCount:10];
    return option;
}
- (PYOption *)getOption2{
   
    NSMutableArray *saveDataArr;
    NSMutableArray *saveDataArr2;
    if(_dataModel.dataArr.count>0){
        saveDataArr = [NSMutableArray arrayWithArray:_dataModel.dataArr[0]];
        if(saveDataArr.count == 0){
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
        NSNumber *time = [NSNumber numberWithLongLong:currentTime];
        NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
        }
    }if(_dataModel.dataArr.count>1){
           saveDataArr2 = [NSMutableArray arrayWithArray:_dataModel.dataArr[1]];
           if(saveDataArr2.count == 0){
           long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
           NSNumber *time = [NSNumber numberWithLongLong:currentTime];
           NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
           saveDataArr2 = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
           }
    }

    NSString *titleStr = [NSString stringWithFormat:@"%@%@",_dataModel.deviceType,@"曲线图"];

    PYOption *option = [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
            .subtextEqual(@"");
        }])
        .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@40).x2Equal(@40).y2Equal(@80).yEqual(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
//            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
        }])
        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"定位锁闭力",@"反位锁闭力"]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@8)
            .scaleEqual(YES)
            .splitLineEqual([PYAxisSplitLine initPYAxisSplitLineWithBlock:^(PYAxisSplitLine *splitLine) {
                splitLine.showEqual(NO);
            }])
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}:${ss}`;})");
                
            }]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue).scaleEqual(YES).boundaryGapEqual(@[@"2.5%",@"2.5%"]);
//            .minEqual(@(-1000))
//            .maxEqual(@(4000));
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
//        series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES)
            series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(@"定位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(@"average");
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
        series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(@"反位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr2).samplingEqual(@"average");
        }]);
    }];
    [DEVICETOOL changeReport:option reportArr:_results maxCount:10];
    return option;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
