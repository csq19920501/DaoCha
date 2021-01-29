//
//  TestDataModel.h
//  TrackCheck
//
//  Created by ethome on 2021/1/14.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDB.h"
NS_ASSUME_NONNULL_BEGIN

@interface TestDataModel : LPDBModel

@property (nonatomic,strong)NSString *station;
@property (nonatomic,strong)NSString *roadSwitch;
@property (nonatomic,strong)NSString *deviceType;
@property (nonatomic,strong)NSString *idStr;
//@property (nonatomic,strong)NSNumber *time;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,assign)long long timeLong ;

@property (nonatomic,strong)NSMutableArray * reportArr;

@end

NS_ASSUME_NONNULL_END
