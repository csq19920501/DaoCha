//
//  ViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/6.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "ViewController.h"
#import "RMMapper.h"
#import "iOS-Echarts.h"
#import "PYEchartsView.h"
#import "PYZoomEchartsView.h"
#import "PYDemoOptions.h"
#import "CSQScoketService.h"
#import "Device.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView1;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView2;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView3;

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarItem;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic ,strong)NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChange) name:DEVICECHANGE object:nil];
    
//    [_kEchartView1 setOption:[self irregularLine2Option1]];
//    [_kEchartView1 loadEcharts];
//
//    [_kEchartView2 setOption:[self irregularLine2Option2]];
//    [_kEchartView2 loadEcharts];
//
//    [_kEchartView3 setOption:[self irregularLine2Option3]];
//    [_kEchartView3 loadEcharts];
    
    self.leftBarItem.title = [NSString stringWithFormat:@"%@%@",[DeviceTool shareInstance].stationStr,[DeviceTool shareInstance].roadSwitchNo];
    [self startScoketService];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
    
    
//    NSMutableArray* d = [NSMutableArray array];int len = 0;NSDate* now = [NSDate date];
//    while (len++ < 200) {
//        long a = len + 3000;
//        [d addObject:@[@(1610190577000),@(a)]];
//        
//    };
//    NSLog(@"测试可变数据 d = %@",d);
    
}
- (IBAction)signmentChange:(id)sender {
    UISegmentedControl   *control = sender;
    NSLog(@"control.selectedSegmentIndex = %ld",(long)control.selectedSegmentIndex);
    if(control.selectedSegmentIndex == 1){
        [self.timer setFireDate:[NSDate distantFuture]];
    }else{
        [self.timer setFireDate:[NSDate date]];
    }
}

- (IBAction)butClick:(id)sender {
    NSLog(@"butClick");
    UIButton *but = sender;
    but.selected = !but.selected;
    if(but == _firstButton){
        [self.kEchartView1 setHidden:!self.firstButton.selected];
    }else if(but == _secondButton){
        [self.kEchartView1 setHidden:!self.firstButton.selected];
    }else if(but == _threeButton){
        [self.kEchartView1 setHidden:!self.firstButton.selected];
    }

}
-(void)changeView{
    
        if(!self.kEchartView1.hidden ){
            [_kEchartView1 setOption:[self irregularLine2Option1]];
            [self.kEchartView1 loadEcharts];
        }
        if(!self.kEchartView2.hidden ){
                   [self.kEchartView2 loadEcharts];
               }
        if(!self.kEchartView3.hidden){
            [self.kEchartView3 loadEcharts];
        }
}
-(void)deviceChange{
    NSLog(@"设备状态变化");
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
//    AppDelegate *delegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    DeviceTool *delegate = [DeviceTool shareInstance];
    self.firstButton.hidden = YES;
    self.secondButton.hidden = YES;
    self.threeButton.hidden = YES;
//        self.firstButton.superview.hidden = YES;
//        self.secondButton.superview.hidden = YES;
//        self.threeButton.superview.hidden = YES;
        int needLoad = -1;
    for(int a = 0;a<delegate.deviceArr.count;a++){
        Device *device = delegate.deviceArr[a];
        UIButton *but = nil;
        if(a == 0){
            but = self.firstButton;
        }else if(a == 1){
            but = self.secondButton;
        }else if(a == 2){
            but = self.threeButton;
        }
        if(device.fitstAdd){
            needLoad = a;
            device.fitstAdd = NO;
        }
        if(but){
            but.hidden = NO;
                   but.titleLabel.text = device.typeStr;
                   but.selected = device.selected;
                   if(device.offline){
                       but.titleLabel.textColor = [UIColor lightGrayColor];
                   }else{
                       but.titleLabel.textColor = [UIColor blackColor];
                   }
        }
       
    }
        
        [weakSelf.kEchartView1 setHidden:!weakSelf.firstButton.selected];
        weakSelf.kEchartView2.hidden = !weakSelf.secondButton.selected;
        weakSelf.kEchartView3.hidden = !weakSelf.threeButton.selected;
        
//        if(!weakSelf.kEchartView1.hidden && needLoad == 0){
//            [weakSelf.kEchartView1 loadEcharts];
//        }
//        if(!weakSelf.kEchartView2.hidden && needLoad == 1){
//                   [weakSelf.kEchartView2 loadEcharts];
//               }
//        if(!weakSelf.kEchartView3.hidden && needLoad == 2){
//            [weakSelf.kEchartView3 loadEcharts];
//        }
        if(!self.firstButton.hidden && !self.firstButton.hidden && !self.firstButton.hidden){
            self.addButton.hidden = YES;
        }else{
            self.addButton.hidden = NO;
        }
    });
}
-(void)startScoketService{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        // 这里放异步执行任务代码
    });
}
- (PYOption *)irregularLine2Option1 {
    NSArray *dataArr = @[@[@(1610190577000),@(0)]];
//     NSArray *dataArr = [NSArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr1];
//    NSLog(@"dataArr = %@",dataArr);
    
    return [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(@"J1曲线图")
            .subtextEqual(@"");
        }])
         .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@40).x2Equal(@50).y2Equal(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerItem)
//            .axisPointerEqual([PYAxisPointer initPYAxisPointerWithBlock:^(PYAxisPointer *axisPoint) {
//                axisPoint.showEqual(YES)
//                .typeEqual(PYAxisPointerTypeCross)
//                .lineStyleEqual([PYLineStyle initPYLineStyleWithBlock:^(PYLineStyle *lineStyle) {
//                    lineStyle.typeEqual(PYLineStyleTypeDashed)
//                    .widthEqual(@1);
//                }]);
//            }])
            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data = date.getFullYear() + \'-\' + (date.getMonth() + 1) + \'-\' + date.getDate() + \' \' + date.getHours() + \':\' + date.getMinutes(); return data + \'<br/>\' + params.value[1] })");
        }])
        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"道岔检测"]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@8)
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();min = min.toString();min = min.toString(); if(min.length <2){min = '0'+min};return `${hour}:${min}`;})");
                
            }]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue)
            .minEqual(@(-1000))
            .maxEqual(@(4000));
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
        series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"道岔检测").typeEqual(PYSeriesTypeLine).dataEqual(dataArr);
        }]);
    }];
//    @"(function () {var d = [];var len = 0;var now = new Date();var value;while (len++ < 200) {d.push([new Date(2014, 9, 1, 0, len * 10000),(Math.random()*3000).toFixed(2) - 300,(Math.random()*100).toFixed(2) - 0]);}return d;})()"
}
- (PYOption *)irregularLine2Option2 {
    return [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(@"J2曲线图")
            .subtextEqual(@"");
        }])
        .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@40).x2Equal(@50).y2Equal(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerItem)
            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data = date.getFullYear() + \'-\' + (date.getMonth() + 1) + \'-\' + date.getDate() + \' \' + date.getHours() + \':\' + date.getMinutes(); return data + \'<br/>\' + params.value[1] + \',\' + params.value[2]})");
        }])
        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"道岔检测"]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@10);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue);
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"道岔检测").typeEqual(PYSeriesTypeLine).dataEqual(@"(function () {var d = [];var len = 0;var now = new Date();var value;while (len++ < 200) {d.push([new Date(2014, 9, 1, 0, len * 10000),(Math.random()*3000).toFixed(2) - 300,(Math.random()*100).toFixed(2) - 0]);}return d;})()");
        }]);
    }];
}
- (PYOption *)irregularLine2Option3 {
    return [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(@"J3曲线图")
            .subtextEqual(@"");
        }])
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@40).x2Equal(@50).y2Equal(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerItem)
            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data = date.getFullYear() + \'-\' + (date.getMonth() + 1) + \'-\' + date.getDate() + \' \' + date.getHours() + \':\' + date.getMinutes(); return data + \'<br/>\' + params.value[1] + \',\' + params.value[2]})");
        }])
        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"道岔检测"]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@10);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue);
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"道岔检测").typeEqual(PYSeriesTypeLine).dataEqual(@"(function () {var d = [];var len = 0;var now = new Date();var value;while (len++ < 200) {d.push([new Date(2014, 9, 1, 0, len * 10000),(Math.random()*3000).toFixed(2) - 300,(Math.random()*100).toFixed(2) - 0]);}return d;})()");
        }]);
    }];
}
@end
