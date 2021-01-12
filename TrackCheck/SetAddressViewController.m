//
//  SetAddressViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/11.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "SetAddressViewController.h"
#import "PYSearch.h"
#import "SetDeviceViewController.h"

#define PYTextColor PYSEARCH_COLOR(113, 113, 113)
#define PYSEARCH_COLORPolRandomColor self.colorPol[arc4random_uniform((uint32_t)self.colorPol.count)]
@interface SetAddressViewController ()

@property (weak, nonatomic) IBOutlet UITextField *stationTF;
@property (weak, nonatomic) IBOutlet UITextField *daoChaTF;
@property (weak, nonatomic) IBOutlet UIButton *sureBut;
@property (weak, nonatomic) IBOutlet UIView *stationTagsView;
@property (weak, nonatomic) IBOutlet UIView *daoChaTagsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stationTagsViewH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *daoChaTagsViewH;

@property (nonatomic, strong) NSMutableArray<UIColor *> *colorPol;
@end

@implementation SetAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sureBut.backgroundColor = BLUECOLOR;
    _sureBut.layer.masksToBounds = YES;
    _sureBut.layer.cornerRadius = 10;
    _stationTF.layer.cornerRadius = 8;
    _stationTF.layer.borderColor = BLUECOLOR.CGColor;
    _stationTF.layer.masksToBounds = YES;
    _stationTF.layer.borderWidth = 2;
    _daoChaTF.layer.cornerRadius = 6;
    _daoChaTF.layer.borderWidth = 2;
    _daoChaTF.layer.borderColor = BLUECOLOR.CGColor;
    _daoChaTF.layer.masksToBounds = YES;
    
    _stationTF.text = DEVICETOOL.stationStr;
    _daoChaTF.text = DEVICETOOL.roadSwitchNo;
    [_sureBut.titleLabel setTextColor:[UIColor whiteColor]];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [self setStationTagesView];
    [self setDaoChaTagesView];
}
-(void)viewDidLayoutSubviews{
    
}
-(void)tagDidCLick:(UIGestureRecognizer*)gesture{
    UILabel *label = (UILabel *)gesture.view;
    _stationTF.text = label.text;
}
-(void)tagDidCLick2:(UIGestureRecognizer*)gesture{
    UILabel *label = (UILabel *)gesture.view;
    _daoChaTF.text = label.text;
}
- (IBAction)empty:(id)sender {
    UIButton *but = (UIButton *)sender;
    if(but.tag == 101){
        [DEVICETOOL.stationStrArr removeAllObjects];
         [self setStationTagesView];
    }else{
        [DEVICETOOL.roadSwitchNoArr removeAllObjects];
        [self setDaoChaTagesView];
    }
    [DEVICETOOL syncArr];
}
- (IBAction)sureClick:(id)sender {
    if(_stationTF.text.length == 0){
       [HUD showAlertWithText:@"站点名称不能为空"];
        return;
    }else if(_daoChaTF.text.length == 0){
       [HUD showAlertWithText:@"道岔号不能为空"];
        return;
    }
    NSArray *copyArr = [NSArray arrayWithArray:DEVICETOOL.stationStrArr];
    BOOL exit = NO;
    for (NSString *str in copyArr) {
        if([str isEqualToString:_stationTF.text]){
            NSUInteger index = [copyArr indexOfObject:str];
            [DEVICETOOL.stationStrArr removeObjectAtIndex:index];
            [DEVICETOOL.stationStrArr insertObject:str atIndex:0];
            exit = YES;
        }
    }
    if(!exit){
       [DEVICETOOL.stationStrArr insertObject:_stationTF.text atIndex:0];
    }
    DEVICETOOL.stationStr = _stationTF.text;
    if(DEVICETOOL.stationStrArr.count >12){
        [DEVICETOOL.stationStrArr removeLastObject];
    }
    
    NSArray *copySwitchArr = [NSArray arrayWithArray:DEVICETOOL.roadSwitchNoArr];
    BOOL exitSwitch = NO;
    for (NSString *str in copySwitchArr) {
        if([str isEqualToString:_daoChaTF.text]){
            NSUInteger index = [copySwitchArr indexOfObject:str];
            [DEVICETOOL.roadSwitchNoArr removeObjectAtIndex:index];
            [DEVICETOOL.roadSwitchNoArr insertObject:str atIndex:0];
            exitSwitch = YES;
        }
    }
    if(!exitSwitch){
       [DEVICETOOL.roadSwitchNoArr insertObject:_daoChaTF.text atIndex:0];
    }
    DEVICETOOL.roadSwitchNo = _daoChaTF.text;
    if(DEVICETOOL.roadSwitchNoArr.count >12){
        [DEVICETOOL.roadSwitchNoArr removeLastObject];
    }
    [DEVICETOOL syncArr];
    
    SetDeviceViewController *setDeviceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SetDeviceViewController"];
    [self.navigationController pushViewController:setDeviceVC animated:YES];
    
//    [self setStationTagesView];
//    [self setDaoChaTagesView];
}

-(void)setStationTagesView{
//    NSArray *tagTexts = @[@"杭州南站",@"杭州基地",@"杭州站"];
    NSArray *tagTexts = [NSArray arrayWithArray:DEVICETOOL.stationStrArr];
    [_stationTagsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UILabel *label = [self labelWithTitle:tagTexts[i]];
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        [_stationTagsView addSubview:label];
        [tagsM addObject:label];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    for (int i = 0; i < _stationTagsView.subviews.count; i++) {
        UILabel *subView = _stationTagsView.subviews[i];
        // When the number of search words is too large, the width is width of the contentView
        if (subView.py_width > _stationTagsView.py_width) subView.py_width = _stationTagsView.py_width;
        if (currentX + subView.py_width + PYSEARCH_MARGIN * countRow > _stationTagsView.py_width) {
            subView.py_x = 0;
            subView.py_y = (currentY += subView.py_height) + PYSEARCH_MARGIN * ++countCol;
            currentX = subView.py_width;
            countRow = 1;
        } else {
            subView.py_x = (currentX += subView.py_width) - subView.py_width + PYSEARCH_MARGIN * countRow;
            subView.py_y = currentY + PYSEARCH_MARGIN * countCol;
            countRow ++;
        }
    }
    _stationTagsViewH.constant = CGRectGetMaxY(_stationTagsView.subviews.lastObject.frame);
}
-(void)setDaoChaTagesView{
     NSArray *tagTexts = [NSArray arrayWithArray:DEVICETOOL.roadSwitchNoArr];
    [_daoChaTagsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UILabel *label = [self labelWithTitle:tagTexts[i]];
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick2:)]];
        [_daoChaTagsView addSubview:label];
        [tagsM addObject:label];
    }
    
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    for (int i = 0; i < _daoChaTagsView.subviews.count; i++) {
        UILabel *subView = _daoChaTagsView.subviews[i];
        // When the number of search words is too large, the width is width of the contentView
        if (subView.py_width > _daoChaTagsView.py_width) subView.py_width = _daoChaTagsView.py_width;
        if (currentX + subView.py_width + PYSEARCH_MARGIN * countRow > _daoChaTagsView.py_width) {
            subView.py_x = 0;
            subView.py_y = (currentY += subView.py_height) + PYSEARCH_MARGIN * ++countCol;
            currentX = subView.py_width;
            countRow = 1;
        } else {
            subView.py_x = (currentX += subView.py_width) - subView.py_width + PYSEARCH_MARGIN * countRow;
            subView.py_y = currentY + PYSEARCH_MARGIN * countCol;
            countRow ++;
        }
    }
    _daoChaTagsViewH.constant = CGRectGetMaxY(_daoChaTagsView.subviews.lastObject.frame);
}
- (UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:20];
    label.text = title;
    label.textColor = STRONGLUECOLOR;
    label.backgroundColor = [UIColor py_colorWithHexString:@"#fafafa"];
    label.layer.cornerRadius = 6;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    
    label.layer.borderColor = nil;
    label.layer.borderWidth = 0.0;
    label.backgroundColor = WEAKBLUECOLOR;
    
    [label sizeToFit];
    label.py_width += 20;
    label.py_height += 14;
    return label;
}
- (NSMutableArray *)colorPol
{
    if (!_colorPol) {
        NSArray *colorStrPol = @[@"009999", @"0099cc", @"0099ff", @"00cc99", @"00cccc", @"336699", @"3366cc", @"3366ff", @"339966", @"666666", @"666699", @"6666cc", @"6666ff", @"996666", @"996699", @"999900", @"999933", @"99cc00", @"99cc33", @"660066", @"669933", @"990066", @"cc9900", @"cc6600" , @"cc3300", @"cc3366", @"cc6666", @"cc6699", @"cc0066", @"cc0033", @"ffcc00", @"ffcc33", @"ff9900", @"ff9933", @"ff6600", @"ff6633", @"ff6666", @"ff6699", @"ff3366", @"ff3333"];
        NSMutableArray *colorPolM = [NSMutableArray array];
        for (NSString *colorStr in colorStrPol) {
            UIColor *color = [UIColor py_colorWithHexString:colorStr];
            [colorPolM addObject:color];
        }
        _colorPol = colorPolM;
    }
    return _colorPol;
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
