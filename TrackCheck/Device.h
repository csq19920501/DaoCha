//
//  Device.h
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface Device : NSObject
@property(nonatomic,copy)NSString * id;
//@property(nonatomic,copy)NSString * typeNum;
@property(nonatomic,copy)NSString * typeStr;
@property(nonatomic,copy)NSString * version;

@property(nonatomic,copy)NSString * vol;
@property(nonatomic,copy)NSString * percent;
@property(nonatomic,copy)NSString * charging;

@property(nonatomic,assign)BOOL  selected;
@property(nonatomic,assign)BOOL  fitstAdd;
@property(nonatomic,assign)BOOL  offline;
@property (nonatomic,assign)BOOL looked;
@property (nonatomic,copy)NSString * timeStr;

@property (nonatomic,strong)NSMutableArray * reportArr;

@property (nonatomic,strong)NSMutableArray * colorArr;
@property (nonatomic,strong)NSMutableArray * fanColorArr;
@end

NS_ASSUME_NONNULL_END
