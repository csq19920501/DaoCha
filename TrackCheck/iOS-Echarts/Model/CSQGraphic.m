//
//  CSQGraphic.m
//  TrackCheck
//
//  Created by ethome on 2021/1/27.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CSQGraphic.h"
#import "PYItemStyleProp.h"
@implementation CSQGraphic
- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = @"text";
        _right = @(10);
        _top = @(10);
        _z = @(100);
        _style = @{
            @"fill":@"#333",
            @"text":@"",
            @"font":@"11px Microsoft YaHei"
        };
    }
    return self;
}

PYInitializerImpTemplate(CSQGraphic);

PYPropertyEqualImpTemplate(CSQGraphic, NSString*, type);
PYPropertyEqualImpTemplate(CSQGraphic, id, top);
PYPropertyEqualImpTemplate(CSQGraphic, id, bottom);
PYPropertyEqualImpTemplate(CSQGraphic, id, left);
PYPropertyEqualImpTemplate(CSQGraphic, id, right);
PYPropertyEqualImpTemplate(CSQGraphic, id, style);
PYPropertyEqualImpTemplate(CSQGraphic, NSNumber *, z);

@end
