//
//  CSQGraphic.h
//  TrackCheck
//
//  Created by ethome on 2021/1/27.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSQGraphic : NSObject
@property (nonatomic, strong) NSNumber *z;
@property (nonatomic, copy) NSString * type;
@property (nonatomic, strong) id onclick;
@property (nonatomic, strong) id left;
@property (nonatomic, strong) id top;
@property (nonatomic, strong) id right;
@property (nonatomic, strong) id bottom;
@property (nonatomic, strong) id style;


PYInitializerTemplate(CSQGraphic, graphic);

PYPropertyEqualTemplate(CSQGraphic, NSString*, type);
PYPropertyEqualTemplate(CSQGraphic, id, top);
PYPropertyEqualTemplate(CSQGraphic, id, bottom);
PYPropertyEqualTemplate(CSQGraphic,id, left);
PYPropertyEqualTemplate(CSQGraphic, id, right);
PYPropertyEqualTemplate(CSQGraphic, id, style);
PYPropertyEqualTemplate(CSQGraphic, NSNumber *, z);
PYPropertyEqualTemplate(CSQGraphic, id, onclick);

@end




NS_ASSUME_NONNULL_END
