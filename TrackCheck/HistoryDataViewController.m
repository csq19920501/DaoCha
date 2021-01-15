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
@interface HistoryDataViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet UIButton *seleStationBut;
@property (weak, nonatomic) IBOutlet UIButton *searchBut;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIToolbar *dateTool;
@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isStart;

@end

@implementation HistoryDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray array];
    
    self.startTimeTextField.inputView = self.datePicker;
       self.startTimeTextField.inputAccessoryView = self.dateTool;
       
       self.endTimeTextField.inputView = self.datePicker;
       self.endTimeTextField.inputAccessoryView = self.dateTool;
    
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
//    [_tabView registerClass:[HistoryCell class]  forCellReuseIdentifier:@"HistoryCell"];
    [self searchClick:nil];
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
- (IBAction)cancle:(id)sender {
    [self.startTimeTextField resignFirstResponder];
    
    [self.endTimeTextField resignFirstResponder];
}
- (IBAction)sureDateAction:(id)sender {
    [self.startTimeTextField resignFirstResponder];
    
    [self.endTimeTextField resignFirstResponder];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    if (_isStart) {
        _startTimeTextField.text = [dateFormatter stringFromDate:self.datePicker.date];
    }else{
        _endTimeTextField.text = [dateFormatter stringFromDate:self.datePicker.date];

    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    if (textField == _startTimeTextField) {
        _isStart = YES;
    }else{
        _isStart = NO;
    }
    return YES;
}
- (IBAction)seleStationClick:(id)sender {
    
}
- (IBAction)searchClick:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *startTimeStr = [NSString stringWithFormat:@"%@ %@",_startTimeTextField.text,@"00:00:00"];
    NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
    NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    
    NSString *endTimeStr = [NSString stringWithFormat:@"%@ %@",_endTimeTextField.text,@"23:059:59"];
       NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
       NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];
    
    NSArray <TestDataModel *> * results = [[LPDBManager defaultManager] findModels: [TestDataModel class]
    where: @"station = '%@' and timeLong > %@ and timeLong < %@",_seleStationBut.titleLabel.text,@(startTimeInterval),@(endTimeInterval)];
    _dataArray = [NSMutableArray arrayWithArray:results];
    [_tabView reloadData];
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
