//
//  CSQScoketService.h
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "CheckModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface CSQScoketService : NSObject
//开启服务
- (void)start;
+(CSQScoketService*)shareInstance;
@property (strong, nonatomic) NSArray *testArray;
@property (assign, nonatomic) NSInteger testCount;
@property (assign, nonatomic) NSTimer * timer;
-(void)stopTest1234;
-(void)test1234;
@end

NS_ASSUME_NONNULL_END
