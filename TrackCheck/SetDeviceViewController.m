//
//  SetDeviceViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/12.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "SetDeviceViewController.h"
#import "ViewController.h"
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

@property(nonatomic,assign)CSQROrL rOrL;
@end

@implementation SetDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSArray * array = @[@"101",@"102",@"106",@"201",@"202",@"203",@"301",@"302",@"303",];
    for (NSString * a in array) {
        UIButton *but =(UIButton *)[self.view viewWithTag:[a intValue]];
        but.layer.masksToBounds = YES;
        but.layer.borderColor = BLUECOLOR.CGColor;
        but.layer.borderWidth = 2;
        but.layer.cornerRadius = 10;
    }
    _layerLabel1.hidden = YES;
    _layerLabel2.hidden = YES;
//    _layerLabel1.layer.masksToBounds = YES;
//    _layerLabel1.layer.borderColor = BLUECOLOR.CGColor;
//    _layerLabel1.layer.borderWidth = 2;
//    _layerLabel1.layer.cornerRadius = 10;
//
//    _layerLabel2.layer.masksToBounds = YES;
//    _layerLabel2.layer.borderColor = BLUECOLOR.CGColor;
//    _layerLabel2.layer.borderWidth = 2;
//    _layerLabel2.layer.cornerRadius = 10;
    
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
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self changeView];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
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
        _topLabel.text = @"检测到WiFi未连接,请连接WiFi:666666,密码:88888888";
    }
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
