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
@interface ReportViewController ()<FCChartViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *safeView;
@property (nonatomic,strong)FCChartView *chartV;

@property (nonatomic,strong)FCChartView *chartV2;

@property (nonatomic,assign)NSInteger itemWidth;
@property (nonatomic,assign)NSInteger itemNmuber;
@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       self.view.backgroundColor = [UIColor whiteColor];
}
-(void)viewDidLayoutSubviews{
    [self.safeView addSubview:self.chartV];//真的是这个视图 【UIcolor whitecolor】
    [self.safeView addSubview:self.chartV2];
    self.itemNmuber = 13 ;
    self.itemWidth = self.chartV.frame.size.width/15 ;  //最小单元1/15
}
-(void)layoutSubviews{
    
}
#pragma mark - FCChartViewDataSource

- (NSInteger)chartView:(FCChartView *)chartView numberOfItemsInSection:(NSInteger)section{
    return self.itemNmuber;
}

- (__kindof UICollectionViewCell *)collectionViewCell:(UICollectionViewCell *)collectionViewCell collectionViewType:(FCChartCollectionViewType)type cellForItemAtIndexPath:(NSIndexPath *)indexPath cellForView:(FCChartView*)chartView{
    FCChartCollectionViewCell *cell = (FCChartCollectionViewCell *)collectionViewCell;
    NSInteger section = -1;
    if(chartView == _chartV){
        section = 0;
    }else{
        
    }
    cell.text = [NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row];
    if(type == FCChartCollectionViewTypeSuspendSection){
        
        if(indexPath.section == section + 0 && indexPath.item == 0){
//            cell.text = @"杭州南站道岔转换力测试表";
            cell.textFont = 20;
            cell.borderWidth = 0.0f;
            
            NSString *string = @"                    杭州南站道岔转换力测试表";
            NSMutableAttributedString *mString = [[NSMutableAttributedString alloc]initWithString:string];
            NSRange range = [string rangeOfString:@"杭州南站"];
            [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleThick) range:range];
            cell.textLabel.attributedText = mString;
        }
        else if(indexPath.section == section + 0 && indexPath.item == 11){
//            cell.text = @"2021年1月7日";
            cell.textFont = 16;
            cell.borderWidth = 0.0f;
            
            NSString *string = @"2021年1月7日";
            NSMutableAttributedString *mString = [[NSMutableAttributedString alloc]initWithString:string];
            NSRange range = [string rangeOfString:@"2021"];
            [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
            NSRange range2 = NSMakeRange(5, 1);
            [mString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range2];
            NSRange range3 = NSMakeRange(7, 1);
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
//        cell.text = [NSString stringWithFormat:@"%ld-%ld",indexPath.section,indexPath.row];
    }
    if (indexPath.section%2) {
        cell.cellType = FCChartCollectionViewCellTypeDefault;
        cell.textColor = [UIColor redColor];

    }else{
        cell.textColor = [UIColor blackColor];
        cell.cellType = FCChartCollectionViewCellTypeMax;
    }
    return cell;
}


- (NSInteger)numberOfSectionsInChartView:(FCChartView *)chartView{
    return 20;
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
        NSInteger section = -1;
        if(chartView == _chartV){
            section = 0;
        }else{
            
        }
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
        
    
        
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        return CGSizeMake(90, 50);
//    }
//    // 学号
//    if (indexPath.section == 0 && indexPath.row == 1) {
//        return CGSizeMake(120, 50);
//    }
//    if (indexPath.section == 0) {
//        return CGSizeMake(80, 50);
//    }
//    if (indexPath.row == 0) {
//        return CGSizeMake(90, 40);
//    }
//    if (indexPath.row == 1) {
//        return CGSizeMake(120, 40);
//    }
//    // 合并单元格
//    if (indexPath.row ==3&&indexPath.section==3) {
//        return CGSizeMake(120, 40);
//    }
//    if (indexPath.row ==4&&indexPath.section==3) {
//        return CGSizeMake(40, 40);
//    }
//
//    if (indexPath.row ==8&&indexPath.section==10) {
//        return CGSizeMake(160, 40);
//    }
//    if (indexPath.row ==9&&indexPath.section==10) {
//        return CGSizeMake(0, 40);
//    }
//
//    if (indexPath.row ==2&&indexPath.section==5) {
//        return CGSizeMake(160, 80);
//    }
//    if (indexPath.row ==3&&indexPath.section==5) {
//        return CGSizeMake(0, 40);
//    }
//    if (indexPath.row ==2&&indexPath.section==6) {
//        return CGSizeMake(80, 0);
//    }
//    if (indexPath.row ==3&&indexPath.section==6) {
//        return CGSizeMake(80, 0);
//    }
//
//    return CGSizeMake(80, 40);
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
