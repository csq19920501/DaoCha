//
//  CSQVisualMap.m
//  TrackCheck
//
//  Created by ethome on 2021/3/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CSQVisualMap.h"

@implementation CSQVisualMap
- (instancetype)init
{
    self = [super init];
    if (self) {
//        _show = NO;
//        _dimension = @(1);
//        _pieces = @[@{@"gt":@(100),@"lte":@(150),@"color":@"red"},@{@"gt":@(150),@"color":@"red"}];
    }
    return self;
}
PYInitializerImpTemplate(CSQVisualMap);


PYPropertyEqualImpTemplate(CSQVisualMap, NSNumber *, dimension);
PYPropertyEqualImpTemplate(CSQVisualMap, id, pieces);
PYPropertyEqualImpTemplate(CSQVisualMap, BOOL, show);
@end
