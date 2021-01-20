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
        self.max = -10000;
        self.min = 10000;
        self.startValue = -10000;
    }
    return self;
}
@end
