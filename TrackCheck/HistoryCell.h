//
//  HistoryCell.h
//  TrackCheck
//
//  Created by ethome on 2021/1/14.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface HistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceType;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,strong)TestDataModel *model;
@end

NS_ASSUME_NONNULL_END
