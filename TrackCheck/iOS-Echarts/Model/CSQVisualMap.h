//
//  CSQVisualMap.h
//  TrackCheck
//
//  Created by ethome on 2021/3/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSQVisualMap : NSObject
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NSNumber *dimension;
@property (nonatomic, strong) id pieces;

PYInitializerTemplate(CSQVisualMap, visualMap);

PYPropertyEqualTemplate(CSQVisualMap, BOOL, show);
PYPropertyEqualTemplate(CSQVisualMap, NSNumber *, dimension);
PYPropertyEqualTemplate(CSQVisualMap, id, pieces);
@end

NS_ASSUME_NONNULL_END
