//
//  SetDeviceViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/12.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "SetDeviceViewController.h"

@interface SetDeviceViewController ()
@property (nonatomic ,strong)NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIButton *but1;
@property (weak, nonatomic) IBOutlet UIButton *but2;
@property (weak, nonatomic) IBOutlet UIButton *but3;
@property (weak, nonatomic) IBOutlet UIButton *but4;
@property (weak, nonatomic) IBOutlet UIButton *but5;
@property (weak, nonatomic) IBOutlet UIButton *sureBut;


@end

@implementation SetDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (int i= 101; i<=106; i++) {
        UIButton *but =(UIButton *)[self.view viewWithTag:i];
        but.layer.masksToBounds = YES;
        but.layer.borderColor = BLUECOLOR.CGColor;
        but.layer.borderWidth = 2;
        but.layer.cornerRadius = 10;
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
- (IBAction)seleClick:(id)sender {
    UIButton *but = (UIButton *)sender;
    but.selected = !but.selected;
    NSInteger tag = but.tag - 100;
    for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
        Device *device = DEVICETOOL.deviceArr[i];
        if([device.id intValue] == tag){
            device.selected = but.selected;
            break;
        }
    }
    
}
- (IBAction)sureClick:(id)sender {
    
    
}

-(void)changeView{
    for (int i= 101; i<=105; i++) {
        UIButton *but =(UIButton *)[self.view viewWithTag:i];
//        but.layer.masksToBounds = YES;
//        but.layer.borderColor = BLUECOLOR.CGColor;
//        but.layer.borderWidth = 2;
//        but.layer.cornerRadius = 10;
        but.alpha = 0.2;
        but.enabled = NO;
        but.selected = NO;
        [but setTitle:[NSString stringWithFormat:@"%@%@",DEVICETOOL.deviceNameArr[i-101],@"(未连接)"] forState:UIControlStateNormal];
        
    }
    for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
        Device *device = DEVICETOOL.deviceArr[i];
        UIButton *but = (UIButton *)[self.view viewWithTag:100+ [device.id intValue]];_but1.alpha = 1;
        but.alpha = 1;
        but.enabled = YES;
        but.selected = device.selected;
        [but setTitle:device.typeStr forState:UIControlStateNormal];
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
