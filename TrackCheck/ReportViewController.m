//
//  ReportViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/7.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "ReportViewController.h"
#import "FCChartView.h"
#import "FCChartCollectionViewCell.h"
#import "ReportModel.h"
#import "xlsxwriter.h"
#import "DLCustomAlertController.h"
#import "DLDateSelectController.h"
#import "DLDateAnimation.h"

@interface ReportViewController ()<FCChartViewDataSource,UITextViewDelegate,UIDocumentPickerDelegate>
@property (weak, nonatomic) IBOutlet UIView *safeView;
@property (nonatomic,strong)FCChartView *chartV;
@property (nonatomic,strong)FCChartView *chartV2;
@property (nonatomic,strong)FCChartView *chartV3;

@property (nonatomic,assign)NSInteger itemWidth;
@property (nonatomic,assign)NSInteger itemNmuber;

@property (nonatomic ,strong)NSString *stationStr ;
@property (nonatomic ,strong)NSString *timeStr;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *dataArray1;
@property (nonatomic ,strong) NSMutableArray *dataArray2;
@property (nonatomic ,strong) NSMutableArray *dataArray3;

@property (nonatomic ,strong) NSMutableArray *dataArray1Sele;
@property (nonatomic ,strong) NSMutableArray *dataArray2Sele;
@property (nonatomic ,strong) NSMutableArray *dataArray3Sele;

@property (nonatomic ,strong) UITextView *stationV;
@property (nonatomic ,strong) UITextView *stationV3;
@property (nonatomic ,strong) UITextView *timeV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *importBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *getAllBar;
@property (nonatomic,assign)BOOL isEdit;
@property (nonatomic,assign)BOOL isShowEdit;
// 已加载到的行数
@property (nonatomic, assign) int rowNum;
@property (nonatomic, strong) UIDocumentPickerViewController *documentPickerVC;
@end

static lxw_workbook  *workbook;
static lxw_worksheet *worksheet;

static lxw_format *titleformat;// 各表格标题栏的格式
static lxw_format *leftcontentformat;// 最左侧一列内容的样式
static lxw_format *contentformat;// 内容的样式
static lxw_format *rightcontentformat;// 最右侧一列内容的样式
static lxw_format *leftsumformat;// 最左侧一列小计的样式
static lxw_format *sumformat;// 小计的样式
static lxw_format *rightsumformat;// 最右侧一列小计的样式

static lxw_format *headerFormat;// 最右侧一列小计的样式
static lxw_format *nameFormat;// 最右侧一列小计的样式
static int width = 15;
@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray1 = [NSMutableArray array];
    _dataArray2 = [NSMutableArray array];
    _dataArray3 = [NSMutableArray array];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
       dateFormatter.dateFormat = @"yyyy-MM-dd";
    _timeStr = [dateFormatter stringFromDate:[NSDate date]];
    _stationStr = DEVICETOOL.stationStr;
//    [self setupFormat];
    
//    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemAction)];
//    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
}
- (IBAction)check:(id)sender {
    if(!_isShowEdit){
        if(!_isEdit){
            _isEdit = YES;
            [_checkBar setTitle:@"取消"];
            [_getAllBar setTitle:@"确定"];
            _getAllBar.enabled = YES;
            [_importBar setTitle:@""];
            _importBar.enabled = NO;
        }else{
            _isEdit = NO;
            [_checkBar setTitle:@"对比"];
            _getAllBar.enabled = NO;
            [_getAllBar setTitle:@""];
            
            for (ReportModel *model in _dataArray1) {
                model.isSelected = NO;
            }
            for (ReportModel *model in _dataArray2) {
                model.isSelected = NO;
            }
            for (ReportModel *model in _dataArray3) {
                model.isSelected = NO;
            }
            [_chartV reload];
            [_chartV2 reload];
            [_chartV3 reload];
            
            [_importBar setTitle:@"导出"];
            _importBar.enabled = YES;
        }
    }else{
        _isShowEdit = NO;
        _isEdit = NO;
         [_checkBar setTitle:@"对比"];
        
        
        for (ReportModel *model in _dataArray1) {
            model.isSelected = NO;
        }
        for (ReportModel *model in _dataArray2) {
            model.isSelected = NO;
        }
        for (ReportModel *model in _dataArray3) {
            model.isSelected = NO;
        }
        [_chartV reload];
        [_chartV2 reload];
        [_chartV3 reload];
        
         [_importBar setTitle:@"导出"];
        _importBar.enabled = YES;
    }
    
}

//- (void)backBarButtonItemAction
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
- (IBAction)getAll:(id)sender {
    _isShowEdit = YES;
    _isEdit = NO;
    _getAllBar.enabled = NO;
    [_getAllBar setTitle:@""];
    
    _dataArray1Sele = [NSMutableArray array];
    for (ReportModel *model in _dataArray1) {
        if(model.isSelected){
            [_dataArray1Sele addObject:model];
        }
    }
    
    _dataArray2Sele = [NSMutableArray array];
    for (ReportModel *model in _dataArray2) {
        if(model.isSelected){
            [_dataArray2Sele addObject:model];
        }
    }
    
    _dataArray3Sele = [NSMutableArray array];
    for (ReportModel *model in _dataArray3) {
        if(model.isSelected){
            [_dataArray3Sele addObject:model];
        }
    }
    [_chartV reload];
     [_chartV2 reload];
     [_chartV3 reload];
}



- (IBAction)export:(id)sender {
//    if(_dataArray1.count == 0 && _dataArray2.count == 0 && _dataArray3.count == 0){
//        [HUD showAlertWithText:@"查询结果无报告"];
//        return;
//    }
    
        self.rowNum = 0;
        // 文件保存的路径
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filename = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"report_%@_%@.xlsx",_stationStr,_timeStr]];
        NSLog(@"filename_path:%@",filename);
        workbook  = workbook_new([filename UTF8String]);// 创建新xlsx文件，路径需要转成c字符串
        worksheet = workbook_add_worksheet(workbook, NULL);// 创建sheet
        [self setupFormat];
        
        [self creatReport];
        [self creatReport2];
        [self creatReport3];
        
        workbook_close(workbook);
        
        UIDocumentPickerViewController *documentPickerVC = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:filename] inMode:UIDocumentPickerModeExportToService];
        // 设置代理
        documentPickerVC.delegate = self;
        // 设置模态弹出方式
        documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:documentPickerVC animated:YES completion:nil];
    
}

- (void)searchClick:(id)sender {
    [HUD showBlocking];
    [_dataArray1 removeAllObjects];
    [_dataArray2 removeAllObjects];
    [_dataArray3 removeAllObjects];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *startTimeStr = [NSString stringWithFormat:@"%@ %@",_timeStr,@"00:00:00"];
        NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
        NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
        
        NSString *endTimeStr = [NSString stringWithFormat:@"%@ %@",_timeStr,@"23:59:59"];
        NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
        NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];

        NSArray <ReportModel *> * results = [[LPDBManager defaultManager] findModels: [ReportModel class]
        where: @"station = '%@' and timeLong > %@ and timeLong < %@",_stationStr,@(startTimeInterval),@(endTimeInterval)];
//        _dataArray = [NSMutableArray arrayWithArray:results];
        for(ReportModel *report in results){
            if(report.reportType == 1 || report.reportType == 2){
                [_dataArray1 addObject:report];
            }else  if(report.reportType == 3 || report.reportType == 4){
                [_dataArray2 addObject:report];
            }else{
                [_dataArray3 addObject:report];
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [HUD hideUIBlockingIndicator];
            [_chartV2 reload];
            [_chartV reload];
            [_chartV3 reload];
            
        });
    });
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DEVICETOOL getSavedStationArr];
}
-(void)viewDidLayoutSubviews{
    [self.safeView addSubview:self.chartV];//真的是这个视图 【UIcolor whitecolor】
    [self.safeView addSubview:self.chartV2];
    [self.safeView addSubview:self.chartV3];
    self.chartV3.hidden = YES;
    self.itemNmuber = 13 ;
    self.itemWidth = self.chartV.frame.size.width/15 ;  //最小单元1/15
    [self searchClick:nil];
}

- (IBAction)sigmentChange:(id)sender {
    UISegmentedControl *sen = (UISegmentedControl *)sender;
    if(sen.selectedSegmentIndex == 0){
        _chartV3.hidden = YES;
        _chartV2.hidden = NO;
    }else{
        _chartV3.hidden = NO;
        _chartV2.hidden = YES;
    }
}

#pragma mark - FCChartViewDataSource

- (NSInteger)chartView:(FCChartView *)chartView numberOfItemsInSection:(NSInteger)section{
    if(chartView == _chartV3){
        return self.itemNmuber - 2;
    }else{
        return self.itemNmuber;
    }
}
-(void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath cellForView:(FCChartView*)chartView{
    if(!_isEdit && !_isShowEdit){
        if(chartView == _chartV){
              if(indexPath.section == 0  && indexPath.row == 11){
                  [self getDatePick];
              }
          }else if(chartView == _chartV3){
             
                  if(indexPath.section == 0  && indexPath.row == 9){
                      [self getDatePick];
                  }
              
          }
    }
    
    if(!_isShowEdit && _isEdit){
        if(chartView == _chartV){
            if(indexPath.section >= 4 && indexPath.section - 4 < _dataArray1.count){
                ReportModel * report = _dataArray1[indexPath.section - 4];
                report.isSelected = !report.isSelected;
                [_chartV reloadSection:indexPath];
            }
        }else if(chartView == _chartV3){

            if(indexPath.section >= 4 && indexPath.section - 4 < _dataArray3.count){
                ReportModel * report = _dataArray3[indexPath.section - 4];
                report.isSelected = !report.isSelected;
                [_chartV3 reloadSection:indexPath];
            }
        }
        else if(chartView == _chartV2){
            if(indexPath.section >= 3 && indexPath.section - 3 < _dataArray2.count){
                ReportModel * report = _dataArray2[indexPath.section - 3];
                report.isSelected = !report.isSelected;
                [_chartV2 reloadSection:indexPath];
            }
        }
    }
    NSLog(@"select %ld-- %d",(long)indexPath.row,indexPath.section);
}
- (__kindof UICollectionViewCell *)collectionViewCell:(UICollectionViewCell *)collectionViewCell collectionViewType:(FCChartCollectionViewType)type cellForItemAtIndexPath:(NSIndexPath *)indexPath cellForView:(FCChartView*)chartView{
    FCChartCollectionViewCell *cell = (FCChartCollectionViewCell *)collectionViewCell;
    
    NSInteger section = -1;
    if(chartView == _chartV || chartView == _chartV3){
        section = 0;
    }
    cell.textFont = 14;
    cell.borderWidth = 0.5f;
    cell.text = @"";
    
    if(chartView == _chartV3){
        if(type == FCChartCollectionViewTypeSuspendSection){
            
            if(indexPath.section == section + 0 && indexPath.item == 0){

                  cell.borderWidth = 0.0f;
                  cell.text = @"";
                
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"                     %@道岔锁闭力测试表",_stationStr]];
                [attributedString addAttribute:NSLinkAttributeName
                                         value:@"station://"
                                         range:[[attributedString string] rangeOfString:_stationStr]];
                if(!_stationV3){
                    _stationV3 = [[UITextView  alloc]init];
                                _stationV3.attributedText = attributedString;
                                _stationV3.frame = cell.contentView.bounds;
                                _stationV3.editable = NO;
                                _stationV3.delegate = self;
                                _stationV3.backgroundColor = [UIColor clearColor];
                               
                                [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:23] range:NSMakeRange(0, attributedString.length)];
                                _stationV3.attributedText = attributedString;
                                _stationV3.linkTextAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
                                 [self contentSizeToFit:_stationV3];
                }
                 [cell.contentView addSubview:_stationV3];
                
            }
            else if(indexPath.section == section + 0 && indexPath.item == 9){
                cell.textFont = 16;
                cell.borderWidth = 0.0f;
                NSRange range = NSMakeRange(0, 4);
                NSRange range2 = NSMakeRange(5, 2);
                NSRange range3 = NSMakeRange(8, 2);
                NSString *string1 = [_timeStr stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"年"];
                NSString *string2 = [string1 stringByReplacingCharactersInRange:NSMakeRange(7, 1) withString:@"月"];
                NSString *string = [NSString stringWithFormat:@"%@日",string2];
                NSMutableAttributedString *mString = [[NSMutableAttributedString alloc]initWithString:string];
               
                [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
                
                [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range2];
                
                [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range3];
                cell.textLabel.attributedText = mString;
            }
            else if(indexPath.section == section + 1 && indexPath.item == 0){
                cell.text = @"时间(时分秒)";
            }
            else if(indexPath.section == section + 1 && indexPath.item == 1){
                cell.text = @"道岔号";
            }
            else if(indexPath.section == section + 1 && indexPath.item == 2){
                cell.text = @"牵引号";
            }
            else if(indexPath.section == section + 1 && indexPath.item == 3){
                cell.text = @"定扳反";
                
            }
            else if(indexPath.section == section + 1 && indexPath.item == 7){
                cell.text = @"反扳定";
            }
            else if(indexPath.section == section + 2 && indexPath.item == 3){
                cell.text = @"锁闭力(KN)";
            }
            else if(indexPath.section == section + 2 && indexPath.item == 5){
                cell.text = @"保持力(KN)";
            }
            else if(indexPath.section == section + 2 && indexPath.item == 7){
                cell.text = @"锁闭力(KN)";
            }
            else if(indexPath.section == section + 2 && indexPath.item == 9){
                cell.text = @"保持力(KN)";
            }
            else if((indexPath.section == section + 3 && indexPath.item == 3)
                || (indexPath.section == section + 3 && indexPath.item == 5)
                     || (indexPath.section == section + 3 && indexPath.item == 7)
                     || (indexPath.section == section + 3 && indexPath.item == 9)
                     
                    ){
                cell.text = @"定位";
            }
            else if((indexPath.section == section + 3 && indexPath.item == 4)
                || (indexPath.section == section + 3 && indexPath.item == 6)
                     || (indexPath.section == section + 3 && indexPath.item == 8)
                     || (indexPath.section == section + 3 && indexPath.item == 10)
                    ){
                cell.text = @"反位";
            }
            cell.textColor = [UIColor blackColor];
        }else{
//            if (indexPath.section%2) {
//                cell.textColor = [UIColor redColor];
//            }else{
//                cell.textColor = [UIColor blackColor];
//            }
            
            
            ReportModel *report;
            if(!_isShowEdit){
                if(indexPath.section < _dataArray3.count){
                    report = _dataArray3[indexPath.section];
                }
            }else{
                if(indexPath.section < _dataArray3Sele.count){
                    report = _dataArray3Sele[indexPath.section];
                }
            }
            
            if(report){
                if(report.isSelected){
                    cell.backgroundColor = BLUECOLOR;
                }else{
                    cell.backgroundColor = [UIColor whiteColor];
                }
                
                 NSLog(@"report.reportType = %ld report..close_fan = %ld ,report.close_ding = %ld",report.reportType,report.close_fan,report.close_ding);
                switch (indexPath.row) {
                    case 0:
                        {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            dateFormatter.dateFormat = @"HH:mm:ss";
                            NSString *startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:report.timeLong]];
                             cell.text = startDate;
                        }
                        break;
                        case 1:
                        {
                             cell.text = report.roadSwitch;
                        }
                        break;
                        case 2:
                        {
                             cell.text = report.deviceType;
                        }
                        break;
                        case 3:
                        {
                            if(report.reportType == 5 || report.reportType == 6){
                                cell.text = report.close_ding!=0?[NSString stringWithFormat:@"%.3f",report.close_ding/1000.0]:@"";
                            }
                            
                        }
                        break;
                        case 4:
                        {
                    
                            if(report.reportType == 5 || report.reportType == 6){
                                cell.text = report.close_fan!=0?[NSString stringWithFormat:@"%.3f",report.close_fan/1000.0]:@"";
                            }
                        }
                        break;
                        case 5:
                                           {
                                 
                                                if(report.reportType == 5 || report.reportType == 6){
                                                    cell.text = report.keep_ding!=0?[NSString stringWithFormat:@"%.3f",report.keep_ding/1000.0]:@"";
                                                }
                                           }
                                           break;
                                           case 6:
                                           {
                                             if(report.reportType == 5 || report.reportType == 6){
                                                                                               cell.text = report.keep_fan!=0?[NSString stringWithFormat:@"%.3f",report.keep_fan/1000.0]:@"";
                                                                                           }
                                           }
                                           break;
                        case 7:
                        {
                     
                            if(report.reportType == 7 || report.reportType == 8){
                                 cell.text = report.close_ding!=0?[NSString stringWithFormat:@"%.3f",report.close_ding/1000.0]:@"";
                             }
                        }
                        break;
                        case 8:
                        {
                           
                             if(report.reportType == 7 || report.reportType == 8){
                                 cell.text = report.close_fan!=0?[NSString stringWithFormat:@"%.3f",report.close_fan/1000.0]:@"";
                             }
                        }
                        break;
                        case 9:
                        {
                           
                             if(report.reportType == 7 || report.reportType == 8){
                                 cell.text = report.keep_ding!=0?[NSString stringWithFormat:@"%.3f",report.keep_ding/1000.0]:@"";
                             }
                        }
                        break;
                        case 10:
                        {
                             
                              if(report.reportType == 7 || report.reportType == 8){
                                                             cell.text = report.keep_fan!=0?[NSString stringWithFormat:@"%.3f",report.keep_fan/1000.0]:@"";
                                                         }
                        }
                        break;
                    default:
                        break;
                }
            
        }
        
        }
        return cell;
    }
    
    
    if(type == FCChartCollectionViewTypeSuspendSection){
        
        if(indexPath.section == section + 0 && indexPath.item == 0){

              cell.borderWidth = 0.0f;
              cell.text = @"";
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"                     %@道岔转换力测试表",_stationStr]];
            [attributedString addAttribute:NSLinkAttributeName
                                     value:@"station://"
                                     range:[[attributedString string] rangeOfString:_stationStr]];
            if(!_stationV){
                _stationV = [[UITextView  alloc]init];
                            _stationV.attributedText = attributedString;
                            _stationV.frame = cell.contentView.bounds;
                            _stationV.editable = NO;
                            _stationV.delegate = self;
                            _stationV.backgroundColor = [UIColor clearColor];
                           
                            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:23] range:NSMakeRange(0, attributedString.length)];
                            _stationV.attributedText = attributedString;
                            _stationV.linkTextAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
                             [self contentSizeToFit:_stationV];
            }
             [cell.contentView addSubview:_stationV];
            
        }
        else if(indexPath.section == section + 0 && indexPath.item == 11){
            cell.textFont = 16;
            cell.borderWidth = 0.0f;
            NSRange range = NSMakeRange(0, 4);
            NSRange range2 = NSMakeRange(5, 2);
            NSRange range3 = NSMakeRange(8, 2);
            NSString *string1 = [_timeStr stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"年"];
            NSString *string2 = [string1 stringByReplacingCharactersInRange:NSMakeRange(7, 1) withString:@"月"];
            NSString *string = [NSString stringWithFormat:@"%@日",string2];
            NSMutableAttributedString *mString = [[NSMutableAttributedString alloc]initWithString:string];
           
            [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
            
            [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range2];
            
            [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range3];
            cell.textLabel.attributedText = mString;
        }
        else if(indexPath.section == section + 1 && indexPath.item == 0){
            cell.text = @"时间(时分秒)";
        }
        else if(indexPath.section == section + 1 && indexPath.item == 1){
            cell.text = @"道岔号";
        }
        else if(indexPath.section == section + 1 && indexPath.item == 2){
            cell.text = @"牵引号";
        }
        else if(indexPath.section == section + 1 && indexPath.item == 3){
            cell.text = @"定扳反(正常转换)";
            if(section == -1){
                cell.text = @"反扳定(正常转换)";
            }
        }
        else if(indexPath.section == section + 1 && indexPath.item == 11){
            cell.text = @"定扳反(受阻空转)(KN)";
            if(section == -1){
                cell.text = @"反扳定(受阻空转)(KN)";
            }
        }
        else if(indexPath.section == section + 2 && indexPath.item == 3){
            cell.text = @"解锁段(KN)";
        }
        else if(indexPath.section == section + 2 && indexPath.item == 5){
            cell.text = @"转换段(KN)";
        }
        else if(indexPath.section == section + 2 && indexPath.item == 7){
            cell.text = @"锁闭段(KN)";
        }
        else if(indexPath.section == section + 2 && indexPath.item == 9){
            cell.text = @"全段(KN)";
        }
        else if((indexPath.section == section + 3 && indexPath.item == 3)
            || (indexPath.section == section + 3 && indexPath.item == 5)
                 || (indexPath.section == section + 3 && indexPath.item == 7)
                 || (indexPath.section == section + 3 && indexPath.item == 9)
                 || (indexPath.section == section + 3 && indexPath.item == 11)
                ){
            cell.text = @"峰值";
        }
        else if((indexPath.section == section + 3 && indexPath.item == 4)
            || (indexPath.section == section + 3 && indexPath.item == 6)
                 || (indexPath.section == section + 3 && indexPath.item == 8)
                 || (indexPath.section == section + 3 && indexPath.item == 10)
                ){
            cell.text = @"均值";
        }
        else if(indexPath.section == section + 3 && indexPath.item == 12){
            cell.text = @"稳态值";
        }
        cell.textColor = [UIColor blackColor];
    }else{
        
//            if (indexPath.section%2) {
//                cell.textColor = [UIColor redColor];
//            }else{
//                cell.textColor = [UIColor blackColor];
//            }
            
        
            if(chartView == _chartV || chartView == _chartV2){
            ReportModel *report;
            if(chartView == _chartV){
                if(!_isShowEdit){
                    if(indexPath.section < _dataArray1.count){
                        report = _dataArray1[indexPath.section];
                    }
                }else{
                    if(indexPath.section < _dataArray1Sele.count){
                        report = _dataArray1Sele[indexPath.section];
                    }
                }
                
            }else if(chartView == _chartV2){
                if(!_isShowEdit){
                    if(indexPath.section < _dataArray2.count){
                        report = _dataArray2[indexPath.section];
                    }
                }else{
                    if(indexPath.section < _dataArray2Sele.count){
                        report = _dataArray2Sele[indexPath.section];
                    }
                }
                
            }
            if(report){
                
                if(report.isSelected){
                    cell.backgroundColor = BLUECOLOR;
                }else{
                    cell.backgroundColor = [UIColor whiteColor];
                }
                switch (indexPath.row) {
                    case 0:
                        {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            dateFormatter.dateFormat = @"HH:mm:ss";
                            NSString *startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:report.timeLong]];
                             cell.text = startDate;
                        }
                        break;
                        case 1:
                        {
                             cell.text = report.roadSwitch;
                        }
                        break;
                        case 2:
                        {
                             cell.text = report.deviceType;
                        }
                        break;
                        case 3:
                        {
                            cell.text = report.open_Top!=0?[NSString stringWithFormat:@"%.3f",report.open_Top/1000.0]:@"";
                        }
                        break;
                        case 4:
                        {
                    
                            cell.text = report.open_mean!=0?[NSString stringWithFormat:@"%.3f",report.open_mean/1000.0]:@"";
                        }
                        break;
                        case 5:
                                           {
                                 
                                                cell.text = report.transform_Top!=0?[NSString stringWithFormat:@"%.3f",report.transform_Top/1000.0]:@"";
                                           }
                                           break;
                                           case 6:
                                           {
                                            
                                                cell.text = report.transform_mean!=0?[NSString stringWithFormat:@"%.3f",report.transform_mean/1000.0]:@"";
                                           }
                                           break;
                        case 7:
                        {
                     
                             cell.text = report.close_Top!=0?[NSString stringWithFormat:@"%.3f",report.close_Top/1000.0]:@"";
                        }
                        break;
                        case 8:
                        {
                           
                             cell.text = report.close_mean!=0?[NSString stringWithFormat:@"%.3f",report.close_mean/1000.0]:@"";
                        }
                        break;
                        case 9:
                        {
                           
                             cell.text = report.all_Top!=0?[NSString stringWithFormat:@"%.3f",report.all_Top/1000.0]:@"";
                        }
                        break;
                        case 10:
                        {
                             
                             cell.text = report.all_mean!=0?[NSString stringWithFormat:@"%.3f",report.all_mean/1000.0]:@"";
                        }
                        break;
                        case 11:
                        {
                          
                             cell.text = report.blocked_Top!=0?[NSString stringWithFormat:@"%.3f",report.blocked_Top/1000.0]:@"";
                        }
                        break;
                        case 12:
                        {
                       
                             cell.text = report.blocked_stable!=0?[NSString stringWithFormat:@"%.3f",report.blocked_stable/1000.0]:@"";
                        }
                        break;
                    default:
                        break;
                }
            }
            
            
        }
    }

    return cell;
}


- (NSInteger)numberOfSectionsInChartView:(FCChartView *)chartView{
    if(chartView == _chartV){
        if(!_isShowEdit){
            return _dataArray1.count <9?9 + 4:_dataArray1.count + 4;
        }else{
            return _dataArray1Sele.count <9?9 + 4:_dataArray1Sele.count + 4;
        }
        
    }else if(chartView == _chartV2){
        if(!_isShowEdit){
            return _dataArray2.count <9?9+3:_dataArray2.count+3;
        }else{
            return _dataArray2Sele.count <9?9+3:_dataArray2Sele.count+3;
        }
        
    }else{
        if(!_isShowEdit){
            return _dataArray3.count <21?21+4:_dataArray3.count+4;
        }else{
            return _dataArray3Sele.count <21?21+4:_dataArray3Sele.count+4;
        }
        
    }
//    return 20;
}

//- (NSInteger)numberOfSuspendSectionsInChartView:(FCChartView *)chartView{
//    if(chartView == _chartV2){
//        return 3;
//    }else{
//        return 4;
//    }
////    return 4;
//}

- (NSInteger)chartView:(FCChartView *)chartView numberOfSuspendItemsInSection:(NSInteger)section{
    return 0;
}

- (CGSize)chartView:(FCChartView *)chartView sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

        NSInteger cellItemWidth  = self.itemWidth;
        NSInteger itemNumber = self.itemNmuber ;
        NSInteger section = -1;
        if(chartView == _chartV || chartView == _chartV3){
            section = 0;
        }
        if(chartView == _chartV3){
            cellItemWidth = self.safeView.frame.size.width/12;
            itemNumber = self.itemNmuber - 2;
        }
    if(chartView == _chartV2 || chartView == _chartV){
        if (indexPath.section == section) {
                              if(indexPath.row == 0){
                                  return CGSizeMake(_itemWidth*12 , 60);
                              }else if (indexPath.row == self.itemNmuber - 2){
                                  return CGSizeMake(_itemWidth*3, 60);
                              }else{
                                  return CGSizeMake(0, 60);
                              }
                              
                          }else if(indexPath.section == section+1){
                              if(indexPath.row == 0){
                                  return CGSizeMake(_itemWidth*2 , 90);
                              }
                              else if (indexPath.row == 1 || indexPath.row == 2){
                                  return CGSizeMake(_itemWidth, 90);
                              }
                              else if(indexPath.row == 3){
                                  return CGSizeMake(_itemWidth*8 , 30);
                              }
                              else if (indexPath.row == self.itemNmuber - 2){
                                  return CGSizeMake(_itemWidth*3, 60);
                              }
                              else if (indexPath.row == self.itemNmuber - 1){
                                  return CGSizeMake(0, 30);
                              }
                              else{
                                  return CGSizeMake(0, 30);
                              }
                          }else if(indexPath.section == section+2){
                              if(indexPath.row == 0){
                                  return CGSizeMake(_itemWidth*2 , 0);
                              }
                              else if (indexPath.row == 1 || indexPath.row == 2){
                                  return CGSizeMake(_itemWidth, 0);
                              }
                              else if(indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 7|| indexPath.row == 9){
                                  return CGSizeMake(_itemWidth*2 , 30);
                              }
                              else if (indexPath.row == self.itemNmuber - 2){
                                  return CGSizeMake(_itemWidth*1.5, 0);
                              }
                              else if (indexPath.row == self.itemNmuber - 1){
                                  return CGSizeMake(0, 30);
                              }
                              else{
                                  return CGSizeMake(0, 30);
                              }
                          }else if(indexPath.section == section+3){
                              if(indexPath.row == 0){
                                  return CGSizeMake(_itemWidth*2 , 0);
                              }
                              else if (indexPath.row == 1 || indexPath.row == 2){
                                  return CGSizeMake(_itemWidth, 0);
                              }
                              
                              else if (indexPath.row == self.itemNmuber - 2 || indexPath.row == self.itemNmuber - 1){
                                  return CGSizeMake(_itemWidth*1.5, 30);
                              }
                              
                              else{
                                  return CGSizeMake(_itemWidth, 30);
                              }
                          }else {
                              if(indexPath.row == 0){
                                  return CGSizeMake(_itemWidth*2, 40);
                              }
                              else if (indexPath.row == self.itemNmuber - 2 || indexPath.row == self.itemNmuber - 1){
                                  return CGSizeMake(_itemWidth*1.5, 40);
                              }
                              else{
                                  return CGSizeMake(_itemWidth, 40);
                              }
                          }
    }else{
         if (indexPath.section == section) {
                               if(indexPath.row == 0){
                                   return CGSizeMake(cellItemWidth*10 , 60);
                               }else if (indexPath.row == itemNumber - 2){
                                   return CGSizeMake(cellItemWidth*2, 60);
                               }else{
                                   return CGSizeMake(0, 60);
                               }
                               
                           }else if(indexPath.section == section+1){
                               if(indexPath.row == 0){
                                   return CGSizeMake(cellItemWidth*2 , 90);
                               }
                               else if (indexPath.row == 1 || indexPath.row == 2){
                                   return CGSizeMake(cellItemWidth, 90);
                               }
                               else if(indexPath.row == 3){
                                   return CGSizeMake(cellItemWidth*4 , 30);
                               }
                               else if (indexPath.row == 7){
                                   return CGSizeMake(cellItemWidth*4, 30);
                               }
        //                       else if (indexPath.row == self.itemNmuber - 1){
        //                           return CGSizeMake(0, 30);
        //                       }
                               else{
                                   return CGSizeMake(0, 30);
                               }
                           }else if(indexPath.section == section+2){
                               if(indexPath.row == 0){
                                   return CGSizeMake(cellItemWidth*2 , 0);
                               }
                               else if (indexPath.row == 1 || indexPath.row == 2){
                                   return CGSizeMake(cellItemWidth, 0);
                               }
                               else if(indexPath.row == 3 || indexPath.row == 5 || indexPath.row == 7|| indexPath.row == 9){
                                   return CGSizeMake(cellItemWidth*2 , 30);
                               }
        //                       else if (indexPath.row == self.itemNmuber - 2){
        //                           return CGSizeMake(_itemWidth*1.5, 0);
        //                       }
        //                       else if (indexPath.row == self.itemNmuber - 1){
        //                           return CGSizeMake(0, 30);
        //                       }
                               else{
                                   return CGSizeMake(0, 30);
                               }
                           }else if(indexPath.section == section+3){
                               if(indexPath.row == 0){
                                   return CGSizeMake(cellItemWidth*2 , 0);
                               }
                               else if (indexPath.row == 1 || indexPath.row == 2){
                                   return CGSizeMake(cellItemWidth, 0);
                               }

                               
                               else{
                                   return CGSizeMake(cellItemWidth, 30);
                               }
                           }else {
                               if(indexPath.row == 0){
                                   return CGSizeMake(cellItemWidth*2, 40);
                               }
        //                       else if (indexPath.row == self.itemNmuber - 2 || indexPath.row == self.itemNmuber - 1){
        //                           return CGSizeMake(_itemWidth*1.5, 40);
        //                       }
                               else{
                                   return CGSizeMake(cellItemWidth, 40);
                               }
                           }
    }
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"station"]) {
        if(!_isEdit && !_isShowEdit){
            NSLog(@"进来了");
                 [self changeStation];
        }
    }
    return YES;
}
-(void)changeStation{
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
            weakSelf.stationStr = dateArray[0] ;
            
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"                     %@道岔转换力测试表",weakSelf.stationStr]];
            [attributedString addAttribute:NSLinkAttributeName
                                     value:@"station://"
                                     range:[[attributedString string] rangeOfString:weakSelf.stationStr]];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:23] range:NSMakeRange(0, attributedString.length)];
            weakSelf.stationV.attributedText = attributedString;
            
            
            NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"                     %@道岔锁闭力测试表",weakSelf.stationStr]];
            [attributedString2 addAttribute:NSLinkAttributeName
                                     value:@"station://"
                                     range:[[attributedString2 string] rangeOfString:weakSelf.stationStr]];
            [attributedString2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:23] range:NSMakeRange(0, attributedString2.length)];
            weakSelf.stationV3.attributedText = attributedString2;

            [weakSelf searchClick:nil];
        }
    };
    [self presentViewController:customAlertC animation:animation completion:nil];
}
-(void)getDatePick{
    DLDateSelectController *dateAlert = [[DLDateSelectController alloc] init];
    DLDateAnimation*  animation = [[DLDateAnimation alloc] init];
    dateAlert.title = @"选择日期";
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
        weakSelf.timeStr = [NSString stringWithFormat:@"%d-%@-%@",year,monthStr,dayStr];
        [weakSelf searchClick:nil];
    };
}
#pragma mark - Getter Methods

- (FCChartView *)chartV{
    
    if (!_chartV) {
        NSInteger allHeight = self.safeView.frame.size.height +60;
        NSInteger a = (int)(allHeight - 240)/40;
        NSInteger bodyHeight = a/2*40;
        _chartV = [[FCChartView alloc] initWithFrame:CGRectMake(0, 0, self.safeView.frame.size.width, bodyHeight + 150) type:FCChartViewTypeOnlySectionFixation dataSource:self suspendSection:4];
        _chartV.layer.borderWidth = 0.5f;
        _chartV.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        _chartV.suspendSection = 4;
        [_chartV registerClass:[FCChartCollectionViewCell class]];
    }
    return _chartV;
}
- (FCChartView *)chartV2{
   
    if (!_chartV2) {
        NSInteger allHeight = self.safeView.frame.size.height + 60;
           NSInteger a = (int)(allHeight - 240)/40;
           NSInteger bodyHeight = a/2*40 ;
        
        _chartV2 = [[FCChartView alloc] initWithFrame:CGRectMake(0, bodyHeight + 150, self.safeView.frame.size.width, bodyHeight + 90 ) type:FCChartViewTypeOnlySectionFixation dataSource:self suspendSection:3];
//        _chartV2.suspendSection = 3;
        [_chartV2 registerClass:[FCChartCollectionViewCell class]];
    }
    return _chartV2;
}
- (FCChartView *)chartV3{
   
    if (!_chartV3) {
        NSInteger allHeight = self.safeView.frame.size.height;
           NSInteger a = (int)(allHeight - 150)/40;
           NSInteger bodyHeight = a*40;
        
        _chartV3 = [[FCChartView alloc] initWithFrame:CGRectMake(0, 0, self.safeView.frame.size.width,bodyHeight + 150) type:FCChartViewTypeOnlySectionFixation dataSource:self suspendSection:4];
//        _chartV2.suspendSection = 3;
        [_chartV3 registerClass:[FCChartCollectionViewCell class]];
    }
    return _chartV3;
}

- (void)contentSizeToFit:(UITextView *)textView
{
    //先判断一下有没有文字（没文字就没必要设置居中了）
    if([textView.text length]>0)
    {
        //textView的contentSize属性
        CGSize contentSize = textView.contentSize;
        //textView的内边距属性
        UIEdgeInsets offset;
        CGSize newSize = contentSize;
        
        //如果文字内容高度没有超过textView的高度
        if(contentSize.height <= textView.frame.size.height)
        {
            //textView的高度减去文字高度除以2就是Y方向的偏移量，也就是textView的上内边距
            CGFloat offsetY = (textView.frame.size.height - contentSize.height)/3;
            offset = UIEdgeInsetsMake(offsetY, 120, 0, 0);
        }
        else          //如果文字高度超出textView的高度
        {
            newSize = textView.frame.size;
            offset = UIEdgeInsetsZero;
            CGFloat fontSize = 20;

           //通过一个while循环，设置textView的文字大小，使内容不超过整个textView的高度（这个根据需要可以自己设置）
            while (contentSize.height > textView.frame.size.height)
            {
                [textView setFont:[UIFont fontWithName:@"Helvetica Neue" size:fontSize--]];
                contentSize = textView.contentSize;
            }
            newSize = contentSize;
        }
        
        //根据前面计算设置textView的ContentSize和Y方向偏移量
        [textView setContentSize:newSize];
        [textView setContentInset:offset];
        
    }
}

// 单元格样式
-(void)setupFormat{
    titleformat = workbook_add_format(workbook);
    format_set_bold(titleformat);
    format_set_font_size(titleformat, 10);
    format_set_align(titleformat, LXW_ALIGN_CENTER);
    format_set_align(titleformat, LXW_ALIGN_VERTICAL_CENTER);//垂直居中
    format_set_border(titleformat, LXW_BORDER_MEDIUM);// 边框（四周）：中宽边框
    
    leftcontentformat = workbook_add_format(workbook);
    format_set_font_size(leftcontentformat, 10);
    format_set_left(leftcontentformat, LXW_BORDER_MEDIUM);// 左边框：中宽边框
    format_set_bottom(leftcontentformat, LXW_BORDER_THIN);// 下边框：双线边框
    format_set_align(leftcontentformat, LXW_ALIGN_CENTER);
    
    contentformat = workbook_add_format(workbook);
    format_set_font_size(contentformat, 10);
    format_set_left(contentformat, LXW_BORDER_THIN);// 左边框：双线边框
    format_set_bottom(contentformat, LXW_BORDER_THIN);// 下边框：双线边框
    format_set_right(contentformat, LXW_BORDER_THIN);// 右边框：双线边框
    format_set_align(contentformat, LXW_ALIGN_CENTER);
    
    rightcontentformat = workbook_add_format(workbook);
    format_set_font_size(rightcontentformat, 10);
    format_set_bottom(rightcontentformat, LXW_BORDER_THIN);// 下边框：双线边框
    format_set_right(rightcontentformat, LXW_BORDER_MEDIUM);// 右边框：中宽边框
    format_set_num_format(rightcontentformat, "￥#,##0.00");
    format_set_align(rightcontentformat, LXW_ALIGN_CENTER);
    
    leftsumformat = workbook_add_format(workbook);
    format_set_font_size(leftsumformat, 10);
    format_set_left(leftsumformat, LXW_BORDER_MEDIUM);// 左边框：中宽边框
    format_set_bottom(leftsumformat, LXW_BORDER_MEDIUM);// 下边框：中宽边框
    
    sumformat = workbook_add_format(workbook);
    format_set_font_size(sumformat, 10);
    format_set_align(sumformat, LXW_ALIGN_RIGHT);// 右对齐
    format_set_left(sumformat, LXW_BORDER_DOUBLE);// 左边框：双线边框
    format_set_bottom(sumformat, LXW_BORDER_MEDIUM);// 下边框：中宽边框
    format_set_right(sumformat, LXW_BORDER_DOUBLE);// 右边框：双线边框
    
    rightsumformat = workbook_add_format(workbook);
    format_set_font_size(rightsumformat, 10);
    format_set_align(rightsumformat, LXW_ALIGN_RIGHT);// 右对齐
    format_set_bottom(rightsumformat, LXW_BORDER_MEDIUM);// 下边框：中宽边框
    format_set_right(rightsumformat, LXW_BORDER_MEDIUM);// 右边框：中宽边框
    format_set_num_format(rightsumformat, "￥#,##0.00");
    
    // 这个表格header标题格式
    headerFormat = workbook_add_format(workbook);
    format_set_font_size(headerFormat, 12);
    format_set_bold(headerFormat);
    format_set_align(headerFormat, LXW_ALIGN_CENTER);//水平居中
    format_set_align(headerFormat, LXW_ALIGN_VERTICAL_CENTER);//垂直居中
    
    // 姓名、报销日期格式
    nameFormat = workbook_add_format(workbook);
    format_set_font_size(nameFormat, 10);
    format_set_bold(nameFormat);
}

-(void)creatReport{
    // 设置列宽
        worksheet_set_column(worksheet, 0, 0, width, NULL);// B、C两列宽度
        worksheet_set_column(worksheet, 1, 10, width * 0.5, NULL);// D列宽度
        worksheet_set_column(worksheet, 11, 12, width * 0.8, NULL);// D列宽度
        
    //    worksheet_write_string(worksheet, self.rowNum, 2, "月报销申请表", headerFormat);
        worksheet_merge_range(worksheet, self.rowNum, 0, self.rowNum, 12, [[NSString stringWithFormat:@"%@道岔转换力定扳反测试表",_stationStr] cStringUsingEncoding:NSUTF8StringEncoding], headerFormat);
        worksheet_merge_range(worksheet, ++self.rowNum, 11, self.rowNum, 12, [_timeStr cStringUsingEncoding:NSUTF8StringEncoding], nameFormat);
        worksheet_merge_range(worksheet, ++self.rowNum, 0, self.rowNum+2, 0, "时间(时分秒)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 1, self.rowNum+2, 1, "道岔号", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 2, self.rowNum+2, 2, "牵引号", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 3, self.rowNum, 10, "定扳反(正常转换)", titleformat);
        
        worksheet_merge_range(worksheet, self.rowNum, 11, self.rowNum+1, 12, "定扳反(受阻空转)(KN)", titleformat);
        
        worksheet_merge_range(worksheet, ++self.rowNum, 3, self.rowNum, 4, "解锁段(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 5, self.rowNum, 6, "转换段(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 7, self.rowNum, 8, "锁闭段(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 9, self.rowNum, 10, "全段(KN)", titleformat);
        
        worksheet_write_string(worksheet, ++self.rowNum, 3, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 4, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 5, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 6, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 7, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 8, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 9, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 10, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 11, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 12, "稳态值", titleformat);
        
        for (int i = 0; i < _dataArray1.count; i++) {
            ReportModel *report = _dataArray[i];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm:ss";
            NSString *startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:report.timeLong]];
            startDate = @"timeLong";
            worksheet_write_string(worksheet, ++self.rowNum, 0, [startDate cStringUsingEncoding:NSUTF8StringEncoding], leftcontentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 1,  [report.roadSwitch cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 2,  [report.deviceType cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
             worksheet_write_string(worksheet, self.rowNum, 3,  [[self changeStr:report.open_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 4,  [[self changeStr:report.open_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 5,  [[self changeStr:report.transform_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 6,  [[self changeStr:report.transform_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 7,  [[self changeStr:report.close_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 8,  [[self changeStr:report.close_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 9,  [[self changeStr:report.all_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 10,  [[self changeStr:report.all_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 11,  [[self changeStr:report.blocked_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 12,  [[self changeStr:report.blocked_stable] cStringUsingEncoding:NSUTF8StringEncoding], rightcontentformat);
            
            
    //        worksheet_write_number(worksheet, self.rowNum, 3, [dic[@"money"] doubleValue], rightcontentformat);
        }
    worksheet_write_string(worksheet, ++self.rowNum, 0, "", NULL);//空白行
    worksheet_write_string(worksheet, ++self.rowNum, 0, "", NULL);//空白行
}

-(void)creatReport2{
    // 设置列宽
        worksheet_set_column(worksheet, 0, 0, width, NULL);// B、C两列宽度
        worksheet_set_column(worksheet, 1, 10, width * 0.5, NULL);// D列宽度
        worksheet_set_column(worksheet, 11, 12, width * 0.8, NULL);// D列宽度
        
        worksheet_merge_range(worksheet, self.rowNum, 0, self.rowNum, 12, [[NSString stringWithFormat:@"%@道岔转换力反扳定测试表",_stationStr] cStringUsingEncoding:NSUTF8StringEncoding], headerFormat);
        worksheet_merge_range(worksheet, ++self.rowNum, 11, self.rowNum, 12, [_timeStr cStringUsingEncoding:NSUTF8StringEncoding], nameFormat);
        worksheet_merge_range(worksheet, ++self.rowNum, 0, self.rowNum+2, 0, "时间(时分秒)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 1, self.rowNum+2, 1, "道岔号", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 2, self.rowNum+2, 2, "牵引号", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 3, self.rowNum, 10, "反扳定(正常转换)", titleformat);
        
        worksheet_merge_range(worksheet, self.rowNum, 11, self.rowNum+1, 12, "反扳定(受阻空转)(KN)", titleformat);
        
        worksheet_merge_range(worksheet, ++self.rowNum, 3, self.rowNum, 4, "解锁段(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 5, self.rowNum, 6, "转换段(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 7, self.rowNum, 8, "锁闭段(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 9, self.rowNum, 10, "全段(KN)", titleformat);
        
        worksheet_write_string(worksheet, ++self.rowNum, 3, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 4, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 5, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 6, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 7, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 8, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 9, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 10, "均值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 11, "峰值", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 12, "稳态值", titleformat);
        
        for (int i = 0; i < _dataArray2.count; i++) {
            ReportModel *report = _dataArray[i];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm:ss";
            NSString *startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:report.timeLong]];
            startDate = @"timeLong";
            worksheet_write_string(worksheet, ++self.rowNum, 0, [startDate cStringUsingEncoding:NSUTF8StringEncoding], leftcontentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 1,  [report.roadSwitch cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 2,  [report.deviceType cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
             worksheet_write_string(worksheet, self.rowNum, 3,  [[self changeStr:report.open_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 4,  [[self changeStr:report.open_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum,5,  [[self changeStr:report.transform_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 6,  [[self changeStr:report.transform_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 7,  [[self changeStr:report.close_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);

            worksheet_write_string(worksheet, self.rowNum, 8,  [[self changeStr:report.close_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 9,  [[self changeStr:report.all_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 10,  [[self changeStr:report.all_mean] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 11,  [[self changeStr:report.blocked_Top] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 12,  [[self changeStr:report.blocked_stable] cStringUsingEncoding:NSUTF8StringEncoding], rightcontentformat);
            
            
    //        worksheet_write_number(worksheet, self.rowNum, 3, [dic[@"money"] doubleValue], rightcontentformat);
        }
    worksheet_write_string(worksheet, ++self.rowNum, 0, "", NULL);//空白行
    worksheet_write_string(worksheet, ++self.rowNum, 0, "", NULL);//空白行
}

-(void)creatReport3{
    // 设置列宽
    int a = 1;
        worksheet_set_column(worksheet, 1-a, 1-a, width, NULL);// B、C两列宽度
        worksheet_set_column(worksheet, 2-a, 11-a, width * 0.5, NULL);// D列宽度
      
        
        worksheet_merge_range(worksheet, self.rowNum, 1-a, self.rowNum, 11-a, [[NSString stringWithFormat:@"%@道岔锁闭力测试表",_stationStr] cStringUsingEncoding:NSUTF8StringEncoding], headerFormat);
        worksheet_merge_range(worksheet, ++self.rowNum, 10-a, self.rowNum, 11-a, [_timeStr cStringUsingEncoding:NSUTF8StringEncoding], nameFormat);
        worksheet_merge_range(worksheet, ++self.rowNum, 1-a, self.rowNum+2, 1-a, "时间(时分秒)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 2-a, self.rowNum+2, 2-a, "道岔号", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 3-a, self.rowNum+2, 3-a, "牵引号", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 4-a, self.rowNum, 7-a, "定扳反", titleformat);
        
        worksheet_merge_range(worksheet, self.rowNum, 8-a, self.rowNum, 11-a, "反扳定", titleformat);
        
        worksheet_merge_range(worksheet, ++self.rowNum, 4-a, self.rowNum, 5-a, "锁闭力(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 6-a, self.rowNum, 7-a, "保持力(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 8-a, self.rowNum, 9-a, "锁闭力(KN)", titleformat);
        worksheet_merge_range(worksheet, self.rowNum, 10-a, self.rowNum, 11-a, "保持力(KN)", titleformat);
        
        worksheet_write_string(worksheet, ++self.rowNum, 4-a, "定位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 5-a, "反位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 6-a, "定位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 7-a, "反位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 8-a, "定位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 9-a, "反位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 10-a, "定位", titleformat);
        worksheet_write_string(worksheet, self.rowNum, 11-a, "反位", titleformat);
 
        
        for (int i = 0; i < _dataArray.count; i++) {
            ReportModel *report = _dataArray3[i];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm:ss";
            NSString *startDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:report.timeLong]];
            startDate = @"timeLong";
            worksheet_write_string(worksheet, ++self.rowNum, 1-a, [startDate cStringUsingEncoding:NSUTF8StringEncoding], leftcontentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 2-a,  [report.roadSwitch cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            worksheet_write_string(worksheet, self.rowNum, 3-a,  [report.deviceType cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            
            if(report.reportType == 5 || report.reportType == 6){
                worksheet_write_string(worksheet, self.rowNum, 4-a,  [[self changeStr:report.close_ding] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 4-a, "", contentformat);
            }
            
            if(report.reportType == 5 || report.reportType == 6){
                worksheet_write_string(worksheet, self.rowNum, 5-a,  [[self changeStr:report.close_fan] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 5-a, "", contentformat);
            }
            
            if(report.reportType == 5 || report.reportType == 6){
                worksheet_write_string(worksheet, self.rowNum, 6-a,  [[self changeStr:report.keep_ding] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 6-a, "", contentformat);
            }
            
            if(report.reportType == 5 || report.reportType == 6){
                worksheet_write_string(worksheet, self.rowNum, 7-a,  [[self changeStr:report.keep_fan] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 7-a, "", contentformat);
            }
            
            if(report.reportType == 7 || report.reportType == 8){
                worksheet_write_string(worksheet, self.rowNum, 8-a,  [[self changeStr:report.close_ding] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 8-a, "", contentformat);
            }
            
            if(report.reportType == 7 || report.reportType == 8){
                worksheet_write_string(worksheet, self.rowNum, 9-a,  [[self changeStr:report.close_fan] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 9-a, "", contentformat);
            }
            if(report.reportType == 7 || report.reportType == 8){
                worksheet_write_string(worksheet, self.rowNum, 10-a,  [[self changeStr:report.keep_ding] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 10-a, "", contentformat);
            }
            
            if(report.reportType == 7 || report.reportType == 8){
                worksheet_write_string(worksheet, self.rowNum, 11-a,  [[self changeStr:report.keep_fan] cStringUsingEncoding:NSUTF8StringEncoding], contentformat);
            }else{
                worksheet_write_string(worksheet, self.rowNum, 11-a, "", contentformat);
            }
            
    //        worksheet_write_number(worksheet, self.rowNum, 3, [dic[@"money"] doubleValue], rightcontentformat);
        }
    worksheet_write_string(worksheet, ++self.rowNum, 0, "", NULL);//空白行
    worksheet_write_string(worksheet, ++self.rowNum, 0, "", NULL);//空白行
}
-(NSString *)changeStr:(NSInteger)nsint{
    return  nsint!=0?[NSString stringWithFormat:@"%.3f",nsint/1000.0]:@"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
