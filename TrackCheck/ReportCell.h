//
//  ReportCell.h
//  TrackCheck
//
//  Created by ethome on 2021/3/5.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *reprotText;
@property (weak, nonatomic) IBOutlet UILabel *reportLabel;

@end

NS_ASSUME_NONNULL_END
