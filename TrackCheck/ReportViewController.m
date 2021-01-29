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

#import "DLCustomAlertController.h"
#import "DLDateSelectController.h"
#import "DLDateAnimation.h"

@interface ReportViewController ()<FCChartViewDataSource,UITextViewDelegate>
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
@property (nonatomic ,strong) UITextView *stationV;
@property (nonatomic ,strong) UITextView *stationV3;
@property (nonatomic ,strong) UITextView *timeV;
@end

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
    }else{
        _chartV3.hidden = NO;
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
            
        }else{
            if (indexPath.section%2) {
                cell.textColor = [UIColor redColor];
            }else{
                cell.textColor = [UIColor blackColor];
            }
          
            ReportModel *report;
            if(indexPath.section < _dataArray3.count){
                report = _dataArray3[indexPath.section];
            }
           
            if(report){
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
            cell.text = @"闭锁段(KN)";
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
    }else{
        
            if (indexPath.section%2) {
                cell.textColor = [UIColor redColor];
            }else{
                cell.textColor = [UIColor blackColor];
            }
            if(chartView == _chartV || chartView == _chartV2){
            ReportModel *report;
            if(chartView == _chartV){
                if(indexPath.section < _dataArray1.count){
                    report = _dataArray1[indexPath.section];
                }
            }else if(chartView == _chartV2){
                if(indexPath.section < _dataArray2.count){
                    report = _dataArray2[indexPath.section];
                }
            }
            if(report){
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
        return _dataArray1.count <9?9 + 4:_dataArray1.count + 4;
    }else if(chartView == _chartV2){
        return _dataArray2.count <9?9+3:_dataArray2.count+3;
    }else{
        return _dataArray3.count <21?21+4:_dataArray3.count+4;
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
        NSLog(@"进来了");
        [self changeStation];
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
        NSInteger allHeight = self.safeView.frame.size.height;
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
        NSInteger allHeight = self.safeView.frame.size.height;
           NSInteger a = (int)(allHeight - 240)/40;
           NSInteger bodyHeight = a/2*40;
        
        _chartV2 = [[FCChartView alloc] initWithFrame:CGRectMake(0, bodyHeight + 150, self.safeView.frame.size.width, bodyHeight + 90) type:FCChartViewTypeOnlySectionFixation dataSource:self suspendSection:3];
//        _chartV2.suspendSection = 3;
        [_chartV2 registerClass:[FCChartCollectionViewCell class]];
    }
    return _chartV2;
}
- (FCChartView *)chartV3{
   
    if (!_chartV3) {
        NSInteger allHeight = self.safeView.frame.size.height;
           NSInteger a = (int)(allHeight - 240)/40;
           NSInteger bodyHeight = a/2*40;
        
        _chartV3 = [[FCChartView alloc] initWithFrame:CGRectMake(0, 0, self.safeView.frame.size.width,allHeight) type:FCChartViewTypeOnlySectionFixation dataSource:self suspendSection:4];
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
