//
//  SetDeviceViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/12.
//  Copyright © 2021 ethome. All rights reserved.
//
#import "TYAlertController.h"
#import "SetDeviceViewController.h"
#import "ViewController.h"
#import "SceneDelegate.h"
#import "CSQScoketService.h"
//#import "DLDateSelectController.h"
//#import "DLDateAnimation.h"
//#import "UIViewController+DLPresent.h"
#import "HLAlertView.h"

#import "DLAlertDemoController.h"
typedef enum:NSInteger{
    None,
    Right,
    Left,
}CSQROrL;
@interface SetDeviceViewController ()
@property (nonatomic ,strong)NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *but1;
@property (weak, nonatomic) IBOutlet UIButton *but2;
@property (weak, nonatomic) IBOutlet UIButton *but3;
@property (weak, nonatomic) IBOutlet UIButton *but4;
@property (weak, nonatomic) IBOutlet UIButton *but5;
@property (weak, nonatomic) IBOutlet UIButton *but6;
@property (weak, nonatomic) IBOutlet UIButton *sureBut;
@property (weak, nonatomic) IBOutlet UILabel *layerLabel1;
@property (weak, nonatomic) IBOutlet UILabel *layerLabel2;
@property (weak, nonatomic) IBOutlet UIView *sigmet2BackView;
@property (weak, nonatomic) IBOutlet UIButton *closeDeviceBut;


@property (weak, nonatomic) IBOutlet UISwitch *debugSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sigmentController;
@property(nonatomic,assign)CSQROrL rOrL;
@property (nonatomic ,strong)TYAlertController *alertController;
@end

@implementation SetDeviceViewController
- (IBAction)switchDebug:(id)sender {
    UISwitch *swi = (UISwitch *)sender;
    if(swi.on){
        
        DEVICETOOL.isDebug = YES;
        [[CSQScoketService shareInstance] addDebugDevice];
    }else{
        DEVICETOOL.isDebug = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _debugSwitch.on = DEVICETOOL.isDebug;
    NSArray * array = @[@"101",@"102",@"106",@"201",@"202",@"203",@"301",@"302",@"303",@"901",@"902",@"903",@"904",@"905",@"906",@"907",@"908",@"909",@"910",];
    for (NSString * a in array) {
        UIButton *but =(UIButton *)[self.view viewWithTag:[a intValue]];
        but.layer.masksToBounds = YES;
        but.layer.borderColor = BLUECOLOR.CGColor;
        but.layer.borderWidth = 2;
        but.layer.cornerRadius = 10;
    }
    _layerLabel1.hidden = YES;
    _layerLabel2.hidden = YES;
    
    
    if(DEVICETOOL.jOrX == J){
        UIButton *but =(UIButton *)[self.view viewWithTag:101];
        but.selected = YES;
        
        UIButton *but2 =(UIButton *)[self.view viewWithTag:102];
        but2.selected = NO;
    }else{
        UIButton *but =(UIButton *)[self.view viewWithTag:102];
        but.selected = YES;
        
        UIButton *but2 =(UIButton *)[self.view viewWithTag:101];
        but2.selected = NO;
    }
    
    if(DEVICETOOL.seleLook == ONE){
        _sigmet2BackView.hidden = YES;
    }else{
        _sigmentController.selectedSegmentIndex = 1;
    }
}
- (IBAction)changeLinkType:(id)sender {
    UIButton *but = (UIButton *)sender;
    if(!but.selected){
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString* linkType = [user stringForKey:[NSString stringWithFormat:@"%@%@CLOSE",DEVICETOOL.stationStr,DEVICETOOL.roadSwitchNo]];
        if(linkType.length > 0){
            if(![but.titleLabel.text isEqualToString:linkType]){
                [self pushAlertView:^(BOOL retu){
                    if(retu){
                        for(int i = 901; i<=909;i++){
                           UIButton *but2 = (UIButton *)[self.view viewWithTag:i];
                           but2.selected = NO;
                        }
                        but.selected = YES;
                        [user setObject:but.titleLabel.text forKey:[NSString stringWithFormat:@"%@%@CLOSE",DEVICETOOL.stationStr,DEVICETOOL.roadSwitchNo]];
                    }
                }];
            }else{
                for(int i = 901; i<=909;i++){
                   UIButton *but2 = (UIButton *)[self.view viewWithTag:i];
                   but2.selected = NO;
                }
                but.selected = YES;
            }
        }else{
           for(int i = 901; i<=909;i++){
               UIButton *but2 = (UIButton *)[self.view viewWithTag:i];
               but2.selected = NO;
            }
            but.selected = YES;
        }
    }
}
-(void)pushAlertView:(void (^)(BOOL))re{
    __weak typeof(self) weakSelf = self;
    TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"提示" message:@"请输入'修改',确认修改操作"];
    
    _alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancle handler:^(TYAlertAction *action) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.alertController dismissViewControllerAnimated:YES];
            if(re){
                re(NO);
            }
        });
    }]];
    
    // 弱引用alertView 否则 会循环引用
    __typeof (alertView) __weak weakAlertView = alertView;
    
    [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
        
        UITextField *textField = [weakAlertView.textFieldArray firstObject];
        
        [textField resignFirstResponder];
        
        if (![textField.text isEqualToString:@"修改"] ){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD showAlertWithText:@"请输入'修改'，确认修改操作"];
            });
            if(re){
                re(NO);
            }
        }else{
         if(re){
             re(YES);
         }
         [weakSelf.alertController dismissViewControllerAnimated:YES];
        }
        
    }]];
    
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.placeholder = @"请输入'修改'";
        
        textField.keyboardType = UIKeyboardTypeNumberPad;
        
        [textField becomeFirstResponder];
    }];
    
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeView];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString* linkType = [user stringForKey:[NSString stringWithFormat:@"%@%@CLOSE",DEVICETOOL.stationStr,DEVICETOOL.roadSwitchNo]];
    for(int i = 901; i<=909;i++){
        UIButton *but = (UIButton *)[self.view viewWithTag:i];
        if([linkType isEqualToString:but.titleLabel.text]){
            but.selected = YES;
        }else{
            but.selected = NO;
        }
    }
    
   
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}
- (IBAction)sigmentChange:(id)sender {
    UISegmentedControl   *control = sender;
        NSLog(@"control.selectedSegmentIndex = %ld",(long)control.selectedSegmentIndex);
        if(control.selectedSegmentIndex == 0){
            DEVICETOOL.seleLook = ONE;
            _sigmet2BackView.hidden = YES;
            
        }else{
            DEVICETOOL.seleLook = TWO;
            _sigmet2BackView.hidden = NO;
        }
}

- (IBAction)changeJOrX:(id)sender {
   
    UIButton *but = (UIButton *)sender;
    if(!but.selected){
        NSArray * array = @[@"201",@"202",@"203",@"301",@"302",@"303",];
        for (NSString * a in array) {
            UIButton *but =(UIButton *)[self.view viewWithTag:[a intValue]];
            but.selected = NO;
        }
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            device.selected = NO;
        }
    }
    but.selected = YES;
    if(but.tag == 101){
        UIButton *but2 =(UIButton *)[self.view viewWithTag:102];
        but2.selected = NO;
        DEVICETOOL.jOrX = J;
        
        _but4.hidden = NO;
        _but5.hidden = NO;
        _but6.hidden = NO;
        
         [_but1 setTitle:@"J1" forState:UIControlStateNormal];
         [_but2 setTitle:@"J2" forState:UIControlStateNormal];
         [_but3 setTitle:@"J3" forState:UIControlStateNormal];
         [_but4 setTitle:@"J4" forState:UIControlStateNormal];
         [_but5 setTitle:@"J5" forState:UIControlStateNormal];
         [_but6 setTitle:@"J6" forState:UIControlStateNormal];
        
    }else if(but.tag == 102){
       UIButton *but2 =(UIButton *)[self.view viewWithTag:101];
        but2.selected = NO;
        DEVICETOOL.jOrX = X;
        
        _but4.hidden = YES;
        _but5.hidden = YES;
        _but6.hidden = YES;
        
         [_but1 setTitle:@"X1" forState:UIControlStateNormal];
         [_but2 setTitle:@"X2" forState:UIControlStateNormal];
         [_but3 setTitle:@"X3" forState:UIControlStateNormal];
    }
    
}
- (IBAction)seleClick:(id)sender {
    UIButton *but = (UIButton *)sender;
    but.selected = !but.selected;
    NSInteger tag = but.tag;
    
    if(tag == 201 || tag == 202 || tag == 203 ){
        if(but.selected){
            _but4.selected = NO;
            _but5.selected = NO;
            _but6.selected = NO;
        }
        if(_rOrL == Right){
            for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
                Device *device = DEVICETOOL.deviceArr[i];
                device.selected = NO;
                device.typeStr = @"";
            }
        }
        _rOrL = Left;
    }
    if(tag == 301 || tag == 302 || tag == 303 ){
        if(but.selected){
            _but1.selected = NO;
            _but2.selected = NO;
            _but3.selected = NO;
        }
        if(_rOrL == Left){
            for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
                Device *device = DEVICETOOL.deviceArr[i];
                device.selected = NO;
                device.typeStr = @"";
            }
        }
        _rOrL = Right;
    }
    
    
    NSString *typeStr;
    long id = 0;
    switch (tag) {
        case 201:
            {
                if(DEVICETOOL.jOrX == J){
                    typeStr = @"J1";
                 
                }else if(DEVICETOOL.jOrX == X){
                    typeStr = @"X1";
                   
                }
                id = 1;
            }
            break;
            case 202:
                       {
                           if(DEVICETOOL.jOrX == J){
                               typeStr = @"J2";
                            
                           }else if(DEVICETOOL.jOrX == X){
                               typeStr = @"X2";
                              
                           }
                           id = 2;
                       }
                       break;
            case 203:
            {
                if(DEVICETOOL.jOrX == J){
                    typeStr = @"J3";
                 
                }else if(DEVICETOOL.jOrX == X){
                    typeStr = @"X3";
                   
                }
                id = 3;
            }
            break;
            case 301:
            {
                
                    typeStr = @"J4";
                
                id = 1;
            }
            break;
            case 302:
            {
                
                    typeStr = @"J5";
                
                id = 2;
            }
            break;
            case 303:
                       {
                          
                           typeStr = @"J6";
                           
                           id = 3;
                       }
                       break;
        default:
            break;
    }
    
    for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
        Device *device = DEVICETOOL.deviceArr[i];
        if([device.id intValue] == (int)id){
            device.selected = but.selected;
            if(device.selected){
                device.typeStr = typeStr;
            }
            break;
        }
    }
    
    
}
- (IBAction)sureClick:(id)sender {
    if(DEVICETOOL.seleLook == ONE){
        BOOL EXIT = NO;
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            if(device.selected){
                EXIT = YES;
                break;
            }
        }
        if(!EXIT){
            [HUD showAlertWithText:@"未选择测试设备"];
            return;
        }
    }
    else if(DEVICETOOL.seleLook == TWO){
        BOOL seleLink = NO;
        NSString *seleType = nil;
        for(int i = 901; i<=909;i++){
            UIButton *but = (UIButton *)[self.view viewWithTag:i];
            if(but.selected){
                seleLink = YES;
                seleType = but.titleLabel.text;
                break;
            }
        }
        if(!seleLink){
            [HUD showAlertWithText:@"未选择锁闭力对应的牵引点"];
        }
        DEVICETOOL.closeLinkDevice = seleType;
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:seleType forKey:[NSString stringWithFormat:@"%@%@CLOSE",DEVICETOOL.stationStr,DEVICETOOL.roadSwitchNo]];
    }
    
    ViewController *setDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:setDeviceVC animated:YES];
}

-(void)changeView{
    
    NSArray * array = @[@"201",@"202",@"203",@"301",@"302",@"303",];
    for (NSString * a in array) {
        UIButton *but =(UIButton *)[self.view viewWithTag:[a intValue]];
        but.alpha = 0.2;
        but.enabled = NO;
//        but.selected = NO;
    }
//    for (int i= 101; i<=105; i++) {
//        UIButton *but =(UIButton *)[self.view viewWithTag:i];
////        but.layer.masksToBounds = YES;
////        but.layer.borderColor = BLUECOLOR.CGColor;
////        but.layer.borderWidth = 2;
////        but.layer.cornerRadius = 10;
//        but.alpha = 0.2;
//        but.enabled = NO;
//        but.selected = NO;
//        [but setTitle:[NSString stringWithFormat:@"%@%@",DEVICETOOL.deviceNameArr[i-101],@"(未连接)"] forState:UIControlStateNormal];
//
//    }
    for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
        Device *device = DEVICETOOL.deviceArr[i];
        int a = [device.id intValue];
        switch (a) {
            case 1:
                {
                    _but1.alpha = 1;
                    _but1.enabled = YES;
                    
                    _but4.alpha = 1;
                    _but4.enabled = YES;
                }
                break;
                case 2:
                               {
                                   _but2.alpha = 1;
                                   _but2.enabled = YES;
                                   
                                   _but5.alpha = 1;
                                   _but5.enabled = YES;
                               }
                               break;
                case 3:
                {
                    _but3.alpha = 1;
                    _but3.enabled = YES;
                    
                    _but6.alpha = 1;
                    _but6.enabled = YES;
                }
                break;
                
            default:
                break;
        }
    }
    
    BOOL isWIFIConnection = [CSQHelper isWIFIConnection];
    if(isWIFIConnection){
        _topLabel.text = @"搜索设备中";
    }else{
        _topLabel.text = @"检测到WiFi未连接,请连接WiFi:WSD_xxxxxxx,密码:12345678";
    }
    
    
    _closeDeviceBut.alpha = 0.2;
    _closeDeviceBut.enabled = NO;
    BOOL hasDing = false ;
    BOOL hasFan = false;
    
    for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
        Device *device = DEVICETOOL.deviceArr[i];
        if([device.id intValue] ==11){
            hasDing = YES;
        }else if([device.id intValue] ==12){
            hasFan = YES;
        }
    }
    if(hasFan && hasDing){
        _closeDeviceBut.alpha = 1;
        _closeDeviceBut.enabled = YES;
    }
}
-(void)getDatePick{
//    DLDateSelectController *dateAlert = [[DLDateSelectController alloc] init];
//    DLDateAnimation*  animation = [[DLDateAnimation alloc] init];
//    [self presentViewController:dateAlert animation:animation completion:nil];
//    dateAlert.selectDate = ^(NSArray * _Nonnull dateArray) {
//        NSLog(@"%@",dateArray);
//    };
//    [self presentViewController:[[DLAlertDemoController alloc]init] animated:YES completion:nil];
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
