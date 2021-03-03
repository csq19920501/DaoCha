//
//  HistoryDataViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/14.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "HistoryDataViewController.h"
#import "HistoryCell.h"
#import "TestDataModel.h"

#import "DLDateSelectController.h"
#import "DLDateAnimation.h"
#import "DLCustomAlertController.h"
#import "HistoryChartViewController.h"
@interface HistoryDataViewController ()<UITableViewDelegate,UITableViewDataSource,DLEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UIButton *seleStationBut;
@property (weak, nonatomic) IBOutlet UIButton *searchBut;

@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isStart;
@property (nonatomic, assign) BOOL firstLoad;
@end

@implementation HistoryDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray array];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *startTime = [dateFormatter stringFromDate:[NSDate date]];
    self.startTimeTextField.text = startTime;
    self.endTimeTextField.text = startTime;
    [self.seleStationBut setTitle:DEVICETOOL.stationStr forState:UIControlStateNormal];
    
    
    NSArray *array = @[_startTimeTextField,_endTimeTextField,_seleStationBut,_searchBut];
    for (UIView* view in array) {
        view.layer.masksToBounds = YES;
        view.layer.borderColor = BLUECOLOR.CGColor;
        view.layer.borderWidth = 2;
        view.layer.cornerRadius = 10;
    }
    [_seleStationBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_searchBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _tabView.dataSetDelegate = self;
    _firstLoad = YES;
    
//    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemAction)];
//       self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
}

//    - (void)backBarButtonItemAction
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_firstLoad){
        _firstLoad = NO;
        [self searchClick:nil];
    }
    
    [DEVICETOOL getSavedStationArr];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 80;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    cell.model = _dataArray[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TestDataModel *model = _dataArray[indexPath.row];
    HistoryChartViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryChartViewController"];
    VC.dataModel = model;
    [self.navigationController pushViewController:VC animated:YES];
}
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableDictionary *attr = [NSMutableDictionary new];
    attr[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attr[NSParagraphStyleAttributeName] = paragraphStyle;

   return [[NSAttributedString alloc]initWithString:@"暂无数据" attributes:attr];
}



- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"famuli_cry_zhubo"];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    if (textField == _startTimeTextField) {
        _isStart = YES;
    }else{
        _isStart = NO;
    }
    [self.startTimeTextField resignFirstResponder];
    [self.endTimeTextField resignFirstResponder];
    [self getDatePick];
    
    return NO;
}
- (IBAction)seleStationClick:(id)sender {
    
    if(DEVICETOOL.savedStationArr.count == 0){
        [HUD showAlertWithText:@"未存储站点"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    DLCustomAlertController *customAlertC = [[DLCustomAlertController alloc] init];
    customAlertC.title = @"选择站点";
    customAlertC.pickerDatas = @[DEVICETOOL.savedStationArr];//arr;
    DLDateAnimation * animation = [[DLDateAnimation alloc] init];
    customAlertC.selectValues = ^(NSArray * _Nonnull dateArray){
        if(dateArray.count > 0){
            [weakSelf.seleStationBut setTitle:dateArray[0] forState:UIControlStateNormal];
        }
    };
    [self presentViewController:customAlertC animation:animation completion:nil];
}
- (IBAction)searchClick:(id)sender {
    
    [HUD showBlocking];
    __weak typeof(self) weakSelf = self;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *startTimeStr = [NSString stringWithFormat:@"%@ %@",_startTimeTextField.text,@"00:00:00"];
    NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
    NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    
    NSString *endTimeStr = [NSString stringWithFormat:@"%@ %@",_endTimeTextField.text,@"23:59:59"];
    NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];
    
    if(startTimeInterval > endTimeInterval){
      
             [HUD showAlertWithText:@"开始时间不能早于结束时间"];
             return;
    }
    NSString *stationS = _seleStationBut.titleLabel.text;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        NSArray <TestDataModel *> * results = [[LPDBManager defaultManager] findModels: [TestDataModel class]
        where: @"station = '%@' and timeLong > %@ and timeLong < %@",stationS,@(startTimeInterval),@(endTimeInterval)];
        weakSelf.dataArray = [NSMutableArray arrayWithArray:results];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tabView reloadData];//为什么重复添加reload 下面方法刷新太慢
            [weakSelf.tabView reloadDataWithEmptyView];
            [HUD hideUIBlockingIndicator];
        });
    });
}
-(void)getDatePick{
    DLDateSelectController *dateAlert = [[DLDateSelectController alloc] init];
    DLDateAnimation*  animation = [[DLDateAnimation alloc] init];
    if(_isStart){
        dateAlert.title = @"开始时间";
    }else{
        dateAlert.title = @"结束时间";
    }
    [self presentViewController:dateAlert animation:animation completion:nil];
    __weak typeof(self) weakSelf = self;
    dateAlert.selectDate = ^(NSArray * _Nonnull dateArray) {
        NSLog(@"%@",dateArray);
        int year = [dateArray[0]  intValue];
        int month = [dateArray[1]  intValue];
        NSString *monthStr = [NSString stringWithFormat:@"%d",month];
        if(monthStr.length<2){
            monthStr = [NSString stringWithFormat:@"0%@",monthStr];
        }
        int day = [dateArray[2]  intValue];
        NSString *dayStr = [NSString stringWithFormat:@"%d",day];
        if(dayStr.length<2){
            dayStr = [NSString stringWithFormat:@"0%@",dayStr];
        }
        if (weakSelf.isStart) {
            weakSelf.startTimeTextField.text = [NSString stringWithFormat:@"%d-%@-%@",year,monthStr,dayStr];
        }else{
            weakSelf.endTimeTextField.text = [NSString stringWithFormat:@"%d-%@-%@",year,monthStr,dayStr];

        }
    };
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
