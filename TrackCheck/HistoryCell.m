//
//  HistoryCell.m
//  TrackCheck
//
//  Created by ethome on 2021/1/14.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(TestDataModel *)model{
    _addressLabel.text = [NSString stringWithFormat:@"地点:%@%@",model.station,model.roadSwitch];
    _deviceType.text = [NSString stringWithFormat:@"牵引点:%@",model.deviceType];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSNumber *timeNum = model.time;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.timeLong];
    NSString *time = [dateFormatter stringFromDate:date];
    _timeLabel.text = time;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
