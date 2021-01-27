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
#import "WKEchartsView.h"
#import "PYDemoOptions.h"
#import "CSQScoketService.h"
#import "Device.h"
#import "SetAddressViewController.h"
#import "SceneDelegate.h"
#import "TestDataModel.h"
#import "ReportModel.h"
#import "TYAlertController.h"
#import "HistoryDataViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView1;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView2;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView3;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView4;
@property (weak, nonatomic) IBOutlet UIView *chartViewBackV;

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
@property (weak, nonatomic) IBOutlet UIButton *saveBut;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChange) name:DEVICECHANGE object:nil];
    _seleJJJArr = [NSMutableArray array];
    self.leftBarItem.title = [NSString stringWithFormat:@"%@%@",[DeviceTool shareInstance].stationStr,[DeviceTool shareInstance].roadSwitchNo];

    DEVICETOOL.testStatus = TestNotStart;
    
    NSArray *butArr2 = @[_changeBut,_startBut,_endBut,_saveBut];
    for (UIButton *but in butArr2) {
        but.layer.masksToBounds = YES;
        but.layer.cornerRadius = 16;
    }
    _endBut.enabled = NO;
    _endBut.alpha = 0.35;
    _saveBut.enabled = NO;
    _saveBut.alpha = 0.35;
    
    
    NSArray *butArr = @[_firstButton,_secondButton,_threeButton];
    for (UIButton *but in butArr) {
        but.layer.masksToBounds = YES;
        but.layer.borderColor = BLUECOLOR.CGColor;
        but.layer.borderWidth = 2;
        but.layer.cornerRadius = 10;
    }
    
     [self initView];
}
-(void)initView{
    NSArray *butArr = @[_firstButton,_secondButton,_threeButton];
    for (UIButton *but in butArr) {
        but.hidden = YES;
        but.selected = NO;
    }
    if(DEVICETOOL.seleLook == ONE){
        [_seleJJJArr removeAllObjects];
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            if(device.selected && [device.id intValue] <=3 ){
                [_seleJJJArr addObject:device];
            }
        }
        for (int i = 0 ; i < _seleJJJArr.count; i++) {
            Device *device = _seleJJJArr[i];
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
            
            if(device.looked){
                but.selected = YES;
            }else{
                but.selected = NO;
            }
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
         _chartViewBackV.hidden = YES;
        self.title = @"阻力转换测试";
    }else{
        _firstButton.hidden = YES;
        _secondButton.hidden = YES;
        _threeButton.hidden = YES;
        _chartViewBackV.hidden  = NO;
        [_kEchartView4 setOption:[self getOption]];
        [_kEchartView4 loadEcharts];
//        [_kEchartView4 refreshEchartsWithOption:[self getOption]];
        self.title = @"锁闭力测试";
    }
}
-(void)viewDidLayoutSubviews{
  // 先执行这个，才执行子页面的layoutSubviews
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [_timer invalidate];
    _timer = nil;
}

- (IBAction)clickLeft:(id)sender {
    if(DEVICETOOL.testStatus == TestStarted){
        [HUD showAlertWithText: @"测试中，不能修改测试地址"];
    }else{
        
        
        
        __weak typeof(self) weakSelf = self;
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"提示" message:@"是否确定修改测试地址"];
            
            TYAlertController * alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancle handler:^(TYAlertAction *action) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertController dismissViewControllerAnimated:YES];

                });
            }]];
            
            // 弱引用alertView 否则 会循环引用
            __typeof (alertView) __weak weakAlertView = alertView;
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
                
                UITextField *textField = [weakAlertView.textFieldArray firstObject];
                
                [textField resignFirstResponder];
                [alertController dismissViewControllerAnimated:YES];
                
                for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
                           Device *device = DEVICETOOL.deviceArr[i];
                           device.selected = NO;
                       }
                       [weakSelf.seleJJJArr removeAllObjects];
                       
                       if([self.navigationController.childViewControllers[0] isKindOfClass:[SetAddressViewController class]]){
                           [self.navigationController popToRootViewControllerAnimated:YES];
                       }else{
                           UIWindow*  window;
                           if (@available(iOS 13.0, *)) {
                             window = [UIApplication sharedApplication].windows[0];
                               
                               NSArray *array =[[[UIApplication sharedApplication] connectedScenes] allObjects];
                               UIWindowScene* windowScene = (UIWindowScene*)array[0];
                               SceneDelegate * delegate = (SceneDelegate *)windowScene.delegate;
                               window = delegate.window;

                           } else {
                             window = [UIApplication sharedApplication].delegate.window;
                           }
                           
                           SetAddressViewController *VC= [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SetAddressViewController"];
                           UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
                           [window setRootViewController:nav];
                       }
                
            }]];
            
          
            [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)signmentChange:(id)sender {
    UISegmentedControl   *control = sender;
    NSLog(@"control.selectedSegmentIndex = %ld",(long)control.selectedSegmentIndex);
    if(control.selectedSegmentIndex == 0){
        _chartViewBackV.hidden = YES;
        for (int i = 0 ; i < _seleJJJArr.count; i++) {
            UIButton * but ;
            if(i == 0){
                but = _firstButton;
            }else if(i == 1){
                but = _secondButton;
            }else if(i == 2){
                but = _threeButton;
            }
            but.hidden = NO;
        }
    }else{
        _firstButton.hidden = YES;
        _secondButton.hidden = YES;
        _threeButton.hidden = YES;
        _chartViewBackV.hidden  = NO;
        [_kEchartView4 refreshEchartsWithOption:[self getOption]];
    }
}
- (IBAction)startTest:(id)sender {
    _startTime = [[NSDate date] timeIntervalSince1970];
    DEVICETOOL.startTime = _startTime;
    
    _startBut.enabled = NO;
    _startBut.alpha = 0.35;
    _changeBut.enabled = NO;
    _changeBut.alpha = 0.35;
    
    _saveBut.enabled = NO;
    _saveBut.alpha = 0.35;
    
    _endBut.enabled = YES;
    _endBut.alpha = 1;
    
    _testTimeLabel.text = @"00:00";
    
    DEVICETOOL.testStatus = TestStarted;
    [DEVICETOOL removeAllData];
    if(DEVICETOOL.isDebug){
        if(DEVICETOOL.seleLook == ONE){
            [[CSQScoketService shareInstance]test1234_];
        }else{
            [[CSQScoketService shareInstance]test1234];
        }
    }

}
- (IBAction)endTest:(id)sender {
    DEVICETOOL.testStatus = TestEnd;
    
     [[CSQScoketService shareInstance]stopTest1234];
    
    _startBut.enabled = YES;
    _startBut.alpha = 1;
    _changeBut.enabled = YES;
    _changeBut.alpha = 1;
    
    _endBut.enabled = NO;
    _endBut.alpha = 0.35;
    
    _saveBut.enabled = YES;
    _saveBut.alpha = 1;
    //保存数据
    
    
}
- (IBAction)changeTest:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)saveClick:(id)sender {
    _saveBut.enabled = NO;
    _saveBut.alpha = 0.35;
    
    if(DEVICETOOL.seleLook == ONE){
        NSMutableArray * saveArray = [NSMutableArray array];
        for (Device *device in DEVICETOOL.deviceArr) {
            if(device.selected ){
                        TestDataModel *dataModel = [[TestDataModel alloc]init];
                        dataModel.station = DEVICETOOL.stationStr;
                        dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                        dataModel.idStr = [NSString stringWithFormat:@"%lld%@",_startTime,device.typeStr];
                        
                        NSMutableArray *dataArray ;
                        switch ([device.id intValue]) {
                            case 1:
                                dataArray = DEVICETOOL.deviceDataArr1;
                                break;
                                case 2:
                                dataArray = DEVICETOOL.deviceDataArr2;
                                break;
                                case 3:
                                dataArray = DEVICETOOL.deviceDataArr3;
                                break;
                                
                            default:
                                break;
                        }
                        dataModel.dataArr = dataArray;
                        dataModel.deviceType = device.typeStr;
                        long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                        dataModel.timeLong = currentTime;
                        [saveArray addObject:dataModel];
                        
            }
        }
        [[LPDBManager defaultManager] saveModels: saveArray];
    }else{
        if(DEVICETOOL.deviceDataArr4.count >0 || DEVICETOOL.deviceDataArr5.count >0){
            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:@[DEVICETOOL.deviceDataArr4,DEVICETOOL.deviceDataArr5]];
            
            TestDataModel *dataModel = [[TestDataModel alloc]init];
            dataModel.station = DEVICETOOL.stationStr;
            dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
            dataModel.idStr = [NSString stringWithFormat:@"%lld%@",_startTime,@"锁闭力"];
                    
            dataModel.dataArr = dataArray;
            dataModel.deviceType = [NSString stringWithFormat:@"%@-锁闭力",DEVICETOOL.closeLinkDevice];
            long long currentTime = [[NSDate date] timeIntervalSince1970] ;
            dataModel.timeLong = currentTime;
            [[LPDBManager defaultManager] saveModels: @[dataModel]];
        }
    }
    [HUD showAlertWithText:@"保存成功"];
}

- (IBAction)butClick:(id)sender {
    return;
    NSLog(@"butClick");
    UIButton *but = sender;
    but.selected = !but.selected;
    if(but == _firstButton){
        [self.kEchartView1 setHidden:!self.firstButton.selected];
        if(!self.kEchartView1.hidden ){
            [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:0]];
        }
    }else if(but == _secondButton){
        [self.kEchartView2 setHidden:!_secondButton.selected];
        if(!self.kEchartView2.hidden ){
        [_kEchartView2 refreshEchartsWithOption:[self irregularLine2Option:1]];
           }
    }else if(but == _threeButton){
        [self.kEchartView3 setHidden:!_threeButton.selected];
        if(!self.kEchartView3.hidden){
               [_kEchartView3 refreshEchartsWithOption:[self irregularLine2Option:2]];
           }
    }


}
-(void)changeView{
    if(DEVICETOOL.testStatus == TestStarted){
     
          
        
        if(self.chartViewBackV.hidden){
                if(!self.kEchartView1.hidden ){
                    
                              BOOL loadChart = NO;
                              Device *device = _seleJJJArr[0];
                              if([device.id intValue] == 1){
                                  if([DeviceTool shareInstance].deviceDataArr1.count<100){
                                      loadChart = YES;
                                      NSLog(@"刚刚开始 loadchart %ld",[DeviceTool shareInstance].deviceDataArr1.count);
                                  }else{
                                      NSLog(@"刚刚开始 refresh");
                                  }
                              }else if([device.id intValue] == 2){
                                  if([DeviceTool shareInstance].deviceDataArr2.count<100){
                                      loadChart = YES;
                                  }
                              }else if([device.id intValue] == 3){
                                  if([DeviceTool shareInstance].deviceDataArr3.count<100){
                                      loadChart = YES;
                                  }
                              }
                    if(loadChart){
                        [_kEchartView1 setOption:[self irregularLine2Option:0]];
                        [_kEchartView1 loadEcharts];
                    }else{
                        [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:0]];
                    }
                    
                }
                if(!self.kEchartView2.hidden ){

                    BOOL loadChart = NO;
                    Device *device = _seleJJJArr[1];
                    if([device.id intValue] == 1){
                        if([DeviceTool shareInstance].deviceDataArr1.count<100){
                            loadChart = YES;
                        }
                    }else if([device.id intValue] == 2){
                        if([DeviceTool shareInstance].deviceDataArr2.count<100){
                            loadChart = YES;
                        }
                    }else if([device.id intValue] == 3){
                        if([DeviceTool shareInstance].deviceDataArr3.count<100){
                            loadChart = YES;
                        }
                    }
                    if(loadChart){
                                           [_kEchartView2 setOption:[self irregularLine2Option:1]];
                                           [_kEchartView2 loadEcharts];
                                       }else{
                                           [_kEchartView2 refreshEchartsWithOption:[self irregularLine2Option:1]];
                                       }
                    
                }
                if(!self.kEchartView3.hidden){
                    BOOL loadChart = NO;
                    Device *device = _seleJJJArr[2];
                    if([device.id intValue] == 1){
                        if([DeviceTool shareInstance].deviceDataArr1.count<100){
                            loadChart = YES;
                        }
                    }else if([device.id intValue] == 2){
                        if([DeviceTool shareInstance].deviceDataArr2.count<100){
                            loadChart = YES;
                        }
                    }else if([device.id intValue] == 3){
                        if([DeviceTool shareInstance].deviceDataArr3.count<100){
                            loadChart = YES;
                        }
                    }
                    if(loadChart){
                        [_kEchartView3 setOption:[self irregularLine2Option:2]];
                        [_kEchartView3 loadEcharts];
                    }else{
                        [_kEchartView3 refreshEchartsWithOption:[self irregularLine2Option:2]];
                    }
                    
                }
        }else{
                [_kEchartView4 refreshEchartsWithOption:[self getOption]];
        }
        
        long long currentTime = [[NSDate date] timeIntervalSince1970];
        NSInteger timeinterval = currentTime - _startTime;
        NSInteger ss = timeinterval%60;
        NSInteger hh = timeinterval/60;
        if(hh ==3){
            ss = 0;
        }
        NSString *ssStr = ss < 10 ? [NSString stringWithFormat:@"0%ld",(long)ss]:[NSString stringWithFormat:@"%ld",(long)ss];
        _testTimeLabel.text = [NSString stringWithFormat:@"0%ld:%@",(long)hh,ssStr];
        if(timeinterval >= 180){
            [self endTest:_endBut];
            [self saveClick:_saveBut];
        }
    }
}

-(void)startScoketService{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        
    });
}
//-(PYOption *)refreshEcharts:(NSInteger)no{
//    if(no>=_seleJJJArr.count){
//        return nil;
//    }
//    NSMutableArray *saveDataArr ;
//    Device *device = _seleJJJArr[no];
//    if([device.id intValue] == 1){
//        saveDataArr = [DeviceTool shareInstance].deviceDataArr1;
//    }else if([device.id intValue] == 2){
//        saveDataArr = [DeviceTool shareInstance].deviceDataArr2;
//    }else if([device.id intValue] == 3){
//        saveDataArr = [DeviceTool shareInstance].deviceDataArr3;
//    }
//    long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
//    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
//    NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
//    if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
//        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
//    }
//     return [PYOption initPYOptionWithBlock:^(PYOption *option) {
//            option.addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
//            series.dataEqual(saveDataArr);
//            }]);
//        }];
//}
- (PYOption *)irregularLine2Option:(NSInteger)no {
    if(no>=_seleJJJArr.count){
        return nil;
    }
    NSMutableArray *saveDataArr ;
    Device *device = _seleJJJArr[no];
    if([device.id intValue] == 1){
        saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr1];
    }else if([device.id intValue] == 2){
        saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr2];
    }else if([device.id intValue] == 3){
        saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr3];
    }
   
    if(saveDataArr.count == 0 && DEVICETOOL.testStatus == TestStarted){
        long long startTime = _startTime *1000;
        NSNumber *time = [NSNumber numberWithLongLong:startTime];
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
        NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }else if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
           NSNumber *time = [NSNumber numberWithLongLong:currentTime];
           NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
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
            grid.xEqual(@60).x2Equal(@40).y2Equal(@80).yEqual(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerItem)
            .axisPointerEqual([PYAxisPointer initPYAxisPointerWithBlock:^(PYAxisPointer *axisPoint) {
                axisPoint.showEqual(YES)
                .typeEqual(PYAxisPointerTypeCross)
                .lineStyleEqual([PYLineStyle initPYLineStyleWithBlock:^(PYLineStyle *lineStyle) {
                    lineStyle.typeEqual(PYLineStyleTypeDashed)
                    .widthEqual(@1);
                }]);
            }])
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
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}:${ss}`;})");
                
            }]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue)
             .nameEqual(@"KN")
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let y = value/1000;return `${y}`;})");
            }]);
//            .minEqual(@(-1000))
//            .maxEqual(@(4000));
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"道岔检测").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr);
        }]);
    }];
}
- (PYOption *)getOption {
   
    NSMutableArray *saveDataArr;
    NSMutableArray *saveDataArr2;
    
    saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr4];
    saveDataArr2 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr5];
   
    if(saveDataArr.count == 0 && DEVICETOOL.testStatus == TestStarted){
        long long startTime = _startTime *1000;
        NSNumber *time = [NSNumber numberWithLongLong:startTime];
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
        NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
        saveDataArr2 = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }else if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
           NSNumber *time = [NSNumber numberWithLongLong:currentTime];
           NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
        saveDataArr2 = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }
    NSString *titleStr = [NSString stringWithFormat:@"%@%@",@"锁闭力",@"曲线图"];
    
    
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
            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
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
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}:${ss}`;})");
                
            }]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue);
//            .minEqual(@(-1000))
//            .maxEqual(@(4000));
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolSizeEqual(@(0)).showAllSymbolEqual(YES).nameEqual(@"定位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(@"average");
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolSizeEqual(@(0)).showAllSymbolEqual(NO).nameEqual(@"反位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr2).samplingEqual(@"average");
        }]);
    }];
}

- (IBAction)showSaveData:(id)sender {
    HistoryDataViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryDataViewController"];
    [self.navigationController pushViewController:VC animated:YES];
}
- (IBAction)closeDeviceBut:(id)sender {
}
@end
