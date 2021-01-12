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
@property (weak, nonatomic) IBOutlet UIButton *changeBut;
@property (weak, nonatomic) IBOutlet UIButton *startBut;
@property (weak, nonatomic) IBOutlet UIButton *endBut;
@property (nonatomic,strong)NSMutableArray *seleJJJArr;
@property (nonatomic ,strong)NSTimer *timer;
@property (nonatomic ,assign)long long startTime;
@property (weak, nonatomic) IBOutlet UILabel *testTimeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChange) name:DEVICECHANGE object:nil];
    
    self.leftBarItem.title = [NSString stringWithFormat:@"%@%@",[DeviceTool shareInstance].stationStr,[DeviceTool shareInstance].roadSwitchNo];

    DEVICETOOL.testStatus = TestNotStart;
    
    NSArray *butArr2 = @[_changeBut,_startBut,_endBut];
    for (UIButton *but in butArr2) {
        but.layer.masksToBounds = YES;
        but.layer.cornerRadius = 16;
    }
    _endBut.enabled = NO;
    _endBut.alpha = 0.2;
    
    
    NSArray *butArr = @[_firstButton,_secondButton,_threeButton];
    for (UIButton *but in butArr) {
        but.layer.masksToBounds = YES;
        but.layer.borderColor = BLUECOLOR.CGColor;
        but.layer.borderWidth = 2;
        but.layer.cornerRadius = 10;
        but.hidden = YES;
        but.selected = NO;
    }
    NSMutableArray *seleJJJArr = [NSMutableArray array];
    _seleJJJArr = seleJJJArr;
    for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
        Device *device = DEVICETOOL.deviceArr[i];
        if(device.selected && [device.id intValue] <=3 ){
            [seleJJJArr addObject:device];
        }
    }
    for (int i = 0 ; i < seleJJJArr.count; i++) {
        Device *device = seleJJJArr[i];
        UIButton * but ;
        if(i == 0){
            but = _firstButton;
        }else if(i == 1){
            but = _secondButton;
        }else if(i == 2){
            but = _threeButton;
        }
        but.hidden = NO;
        [but setTitle:device.typeStr forState:UIControlStateNormal];
        but.selected = YES;
    }
    _kEchartView1.hidden = !_firstButton.selected;
    _kEchartView2.hidden = !_secondButton.selected;
    _kEchartView3.hidden = !_threeButton.selected;
    if(!_kEchartView1.hidden ){
        [_kEchartView1 setOption:[self irregularLine2Option:0]];
        [_kEchartView1 loadEcharts];
    }
    if(!_kEchartView2.hidden ){
        [_kEchartView2 setOption:[self irregularLine2Option:1]];
               [_kEchartView2 loadEcharts];
           }
    if(!_kEchartView3.hidden){
        [_kEchartView3 setOption:[self irregularLine2Option:2]];
        [_kEchartView3 loadEcharts];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [_timer invalidate];
    _timer = nil;
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
- (IBAction)startTest:(id)sender {
    _startTime = [[NSDate date] timeIntervalSince1970];
    
    
    _startBut.enabled = NO;
    _startBut.alpha = 0.2;
    _changeBut.enabled = NO;
    _changeBut.alpha = 0.2;
    
    _endBut.enabled = YES;
    _endBut.alpha = 1;
    
    _testTimeLabel.text = @"00:00";
    
    [DEVICETOOL removeAllData];
    DEVICETOOL.testStatus = TestStarted;
}
- (IBAction)endTest:(id)sender {
    DEVICETOOL.testStatus = TestEnd;
    
    _startBut.enabled = YES;
    _startBut.alpha = 1;
    _changeBut.enabled = YES;
    _changeBut.alpha = 1;
    
    _endBut.enabled = NO;
    _endBut.alpha = 0.2;
    //保存数据
}
- (IBAction)changeTest:(id)sender {
}

- (IBAction)butClick:(id)sender {
    NSLog(@"butClick");
    UIButton *but = sender;
    but.selected = !but.selected;
    if(but == _firstButton){
        [self.kEchartView1 setHidden:!self.firstButton.selected];
    }else if(but == _secondButton){
        [self.kEchartView2 setHidden:!_secondButton.selected];
    }else if(but == _threeButton){
        [self.kEchartView3 setHidden:!_threeButton.selected];
    }

}
-(void)changeView{
    
    if(DEVICETOOL.testStatus == TestStarted){
        
        
                if(!self.kEchartView1.hidden ){
        //            [_kEchartView1 setOption:[self irregularLine2Option:0]];
        //            [self.kEchartView1 loadEcharts];
                    [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:0]];
                }
                if(!self.kEchartView2.hidden ){
                    [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:1]];
                       }
                if(!self.kEchartView3.hidden){
                    [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:2]];
                }
        
        long long currentTime = [[NSDate date] timeIntervalSince1970];
        NSInteger timeinterval = currentTime - _startTime;
        NSInteger ss = timeinterval%60;
        NSInteger hh = timeinterval/60;
        NSString *ssStr = ss < 10 ? [NSString stringWithFormat:@"0%ld",(long)ss]:[NSString stringWithFormat:@"%ld",(long)ss];
        _testTimeLabel.text = [NSString stringWithFormat:@"0%ld:%@",(long)hh,ssStr];
        if(timeinterval >= 180){
            [self endTest:_endBut];
        }
    }
}
//-(void)deviceChange{
//    NSLog(@"设备状态变化");
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
//}
//-(void)startScoketService{
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    // 异步执行任务创建方法
//    dispatch_async(queue, ^{
//        // 这里放异步执行任务代码
//    });
//}
-(PYOption *)refreshEcharts:(NSInteger)no{
    if(no>=_seleJJJArr.count){
        return nil;
    }
    NSMutableArray *saveDataArr ;
    Device *device = _seleJJJArr[no];
    if([device.id intValue] == 1){
        saveDataArr = [DeviceTool shareInstance].deviceDataArr1;
    }else if([device.id intValue] == 2){
        saveDataArr = [DeviceTool shareInstance].deviceDataArr2;
    }else if([device.id intValue] == 3){
        saveDataArr = [DeviceTool shareInstance].deviceDataArr3;
    }
    long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
    NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
    if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }
     return [PYOption initPYOptionWithBlock:^(PYOption *option) {
            option.addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.dataEqual(saveDataArr);
            }]);
        }];
}
- (PYOption *)irregularLine2Option:(NSInteger)no {
    if(no>=_seleJJJArr.count){
        return nil;
    }
    NSMutableArray *saveDataArr ;
    Device *device = _seleJJJArr[no];
    if([device.id intValue] == 1){
        saveDataArr = [DeviceTool shareInstance].deviceDataArr1;
    }else if([device.id intValue] == 2){
        saveDataArr = [DeviceTool shareInstance].deviceDataArr2;
    }else if([device.id intValue] == 3){
        saveDataArr = [DeviceTool shareInstance].deviceDataArr3;
    }
    long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
    NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
    if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }
    NSString *titleStr = [NSString stringWithFormat:@"%@%@",device.typeStr,@"曲线图"];
    
    return [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
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
//             .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data = date.getFullYear() + \'-\' + (date.getMonth() + 1) + \'-\' + date.getDate() + \' \' + date.getHours() + \':\' + date.getMinutes(); return data + \'<br/>\' + params.value[1] })");
            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
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
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}`:${ss}`;})");
                
            }]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue);
//            .minEqual(@(-1000))
//            .maxEqual(@(4000));
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
        series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"道岔检测").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr);
        }]);
    }];
}

@end
