//
//  HistoryChartViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/15.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "HistoryChartViewController.h"
#import "ReportModel.h"
@interface HistoryChartViewController ()<PYEchartsViewDelegate>
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
    
    [HUD showBlocking];
//    if(![type containsString:@"锁闭力"]){
//        [_chartView setOption:[self getOption:@"lttb"]];
//    }else{
//        [_chartView setOption:[self getOption2:@"lttb"]];
//    }
//    [_chartView loadEcharts];
//
        __weak typeof(self) weakSelf = self;
//               dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/*延迟执行时间*/ * NSEC_PER_SEC));
//               dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//      weakSelf.results = [[LPDBManager defaultManager] findModels: [ReportModel class]
//      where: @"idStr = '%@'",weakSelf.dataModel.idStr];
//      NSLog(@"idstr = %@ count = %ld",_dataModel.idStr,_results.count);
    
    _results = [ReportModel mj_objectArrayWithKeyValuesArray:_dataModel.reportArr];
      if(![type containsString:@"锁闭力"]){
          [weakSelf.chartView setOption:[weakSelf getOption:@""]];
      }else{
          [weakSelf.chartView setOption:[weakSelf getOption2:@""]];
      }

    [_chartView loadEcharts];
//        });
//    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemAction)];
//    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

//- (void)backBarButtonItemAction
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
- (void)echartsViewDidFinishLoad:(PYEchartsView *)echartsView{
    [HUD hideUIBlockingIndicator];
}
- (PYOption *)getOption:(NSString*)sample{
   
    NSMutableArray *saveDataArr;
//    NSMutableArray *saveDataArr2;
    saveDataArr = [NSMutableArray arrayWithArray:_dataModel.dataArr];
    if(saveDataArr.count == 0){
    long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
    NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
    saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }
//    saveDataArr = [NSMutableArray array];
//    for (int i =0; i<_dataModel.dataArr.count; i++) {
//        NSArray *data =_dataModel.dataArr[i];
//        NSNumber *num = data[1];
//        long dataLong = num.longValue;
//        if(dataLong>100000 || dataLong<-100000){
//            dataLong = dataLong/3 + 85317 - 32768;
//        }
//        [saveDataArr addObject:@[data[0],@(dataLong)]];
//    }
    
    NSDictionary *visualMapD = @{@"show":@(NO),@"dimension":@(0),@"pieces":@[@{@"lte":@(1614835094000),@"color":blueColor},@{@"gt":@(1614835095000),@"color":blueColor}]};
        if(_dataModel.colorArr.count != 0){
            NSMutableArray *pieces = [NSMutableArray array];
            NSNumber* saveCount = @(0);
            for (int a = 0; a<_dataModel.colorArr.count; a++) {
                NSArray *piece = _dataModel.colorArr[a];
                if(a==0){
                    [pieces addObject:@{@"lte":piece[0],@"color":blueColor}];
                    [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":redColor}];
                    saveCount = piece[1];
                }else{
                    [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":blueColor}];
                    [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":redColor}];
                    saveCount = piece[1];
                }
                if(a == _dataModel.colorArr.count-1){
                     [pieces addObject:@{@"gt":saveCount,@"color":blueColor}];
                }
            }
            visualMapD =  @{@"show":@(NO),@"dimension":@(0),@"pieces":pieces};
        }
    
    NSString *titleStr = [NSString stringWithFormat:@"%@%@",_dataModel.deviceType,@"曲线图"];

    PYOption *option =  [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
            .subtextEqual(@"");
        }])
        .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@60).x2Equal(@40).y2Equal(@80).yEqual(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
//            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"slider");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"inside");
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[titleStr]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@6)
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
            .nameEqual(titleStr).typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(sample);
        }]);
//        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
//        series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"反位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr2);
//        }]);
    }];
    [DEVICETOOL changeReport:option reportArr:_results maxCount:14];
    option.visualMap = visualMapD;
    return option;
}
- (PYOption *)getOption2:(NSString*)sample{
    NSLog(@"data.color.count = %d  %ld  %d",_dataModel.colorArr.count,_dataModel.fanColorArr.count,_dataModel.close_transArr.count);
    
    NSMutableArray *saveDataArr;  //定位
    NSMutableArray *saveDataArr2; //反位
    NSMutableArray *saveDataArr3; //锁闭力
    
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
    }if(_dataModel.dataArr.count>2){
           saveDataArr3 = [NSMutableArray arrayWithArray:_dataModel.dataArr[2]];
           if(saveDataArr3.count == 0){
           long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
           NSNumber *time = [NSNumber numberWithLongLong:currentTime];
           NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
           saveDataArr3 = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
           }
    }

    NSDictionary *visualMapDClose1 = @{@"show":@(NO),@"seriesIndex":@(1),@"dimension":@(0),@"pieces":@[@{@"lte":@(1614835094000),@"color":fanColor},@{@"gt":@(1614835095000),@"color":fanColor}]};
        if(_dataModel.colorArr.count != 0){
            NSMutableArray *pieces = [NSMutableArray array];
            NSNumber* saveCount = @(0);
            for (int a = 0; a<_dataModel.colorArr.count; a++) {
                NSArray *piece = _dataModel.colorArr[a];
                if(a==0){
                    [pieces addObject:@{@"lte":piece[0],@"color":fanColor}];
                    [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":realRedColor}];
                    saveCount = piece[1];
                }else{
                    [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":fanColor}];
                    [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":realRedColor}];
                    saveCount = piece[1];
                }
                if(a == _dataModel.colorArr.count-1){
                     [pieces addObject:@{@"gt":saveCount,@"color":fanColor}];
                }
            }
            visualMapDClose1 =  @{@"show":@(NO),@"seriesIndex":@(1),@"dimension":@(0),@"pieces":pieces};
        }
    NSDictionary *visualMapDClose2 = @{@"show":@(NO),@"seriesIndex":@(2),@"dimension":@(0),@"pieces":@[@{@"lte":@(1614835094000),@"color":close_transform_color},@{@"gt":@(1614835095000),@"color":close_transform_color}]};
    if(_dataModel.fanColorArr.count != 0){
        NSMutableArray *pieces = [NSMutableArray array];
        NSNumber* saveCount = @(0);
        for (int a = 0; a<_dataModel.fanColorArr.count; a++) {
            NSArray *piece = _dataModel.fanColorArr[a];
            if(a==0){
                [pieces addObject:@{@"lte":piece[0],@"color":close_transform_color}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":realRedColor}];
                saveCount = piece[1];
            }else{
                [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":close_transform_color}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":realRedColor}];
                saveCount = piece[1];
            }
            if(a == _dataModel.fanColorArr.count-1){
                 [pieces addObject:@{@"gt":saveCount,@"color":close_transform_color}];
            }
        }
        visualMapDClose2 =  @{@"show":@(NO),@"seriesIndex":@(2),@"dimension":@(0),@"pieces":pieces};
    }
    NSDictionary *visualMapDCHange = @{@"show":@(NO),@"seriesIndex":@(0),@"dimension":@(0),@"pieces":@[@{@"lte":@(1614835094000),@"color":dinColor},@{@"gt":@(1614835095000),@"color":dinColor}]};
    if(_dataModel.close_transArr.count != 0){
        NSMutableArray *pieces = [NSMutableArray array];
        NSNumber* saveCount = @(0);
        for (int a = 0; a<_dataModel.close_transArr.count; a++) {
            NSArray *piece = _dataModel.close_transArr[a];
            if(a==0){
                [pieces addObject:@{@"lte":piece[0],@"color":dinColor}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":realRedColor}];
                saveCount = piece[1];
            }else{
                [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":dinColor}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":realRedColor}];
                saveCount = piece[1];
            }
            if(a == _dataModel.close_transArr.count-1){
                 [pieces addObject:@{@"gt":saveCount,@"color":dinColor}];
            }
        }
        visualMapDCHange =  @{@"show":@(NO),@"seriesIndex":@(0),@"dimension":@(0),@"pieces":pieces};
    }
    
    NSString *titleStr = [NSString stringWithFormat:@"%@%@",_dataModel.deviceType,@"曲线图"];

    PYOption *option = [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
            .subtextEqual(@"");
        }])
        .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@60).x2Equal(@40).y2Equal(@80).yEqual(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
//            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"slider");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"inside");
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"定位锁闭力",@"反位锁闭力",@"转换阻力"]);
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
            .nameEqual(@"转换阻力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr3).samplingEqual(sample);
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
//        series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES) 闭锁
            series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(@"定位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(sample);
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
        series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(@"反位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr2).samplingEqual(sample);
        }]);

        
    }];
    [DEVICETOOL changeReport:option reportArr:_results maxCount:14];
    option.visualMap = @[visualMapDClose1,visualMapDClose2,visualMapDCHange];
    return option;
}
-(void)viewWillDisappear:(BOOL)animated{
    [_chartView removeFromSuperview];
    _chartView = nil;
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
