//
//  CheckModel.m
//  TrackCheck
//
//  Created by ethome on 2021/1/18.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CheckModel.h"

@implementation CheckModel
-(instancetype)init{
    self = [super init];
    if(self){
        self.dataArr = [NSMutableArray array];
        self.timeArr = [NSMutableArray array];
        self.fanTimeArr = [NSMutableArray array];
        self.dataArr_Fan = [NSMutableArray array];
        self.max = -10000;
        self.min = 10000;
        self.max_Fan = -10000;
        self.min_Fan = 10000;
        self.startValue = -10000;
        self.startValue_Fan = -10000;
        self.dataModel = [[ReportModel alloc]init];
        self.dataBlockArr = [NSMutableArray array];
    }
    return self;
}
@end
