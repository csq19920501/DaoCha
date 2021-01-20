//
//  TcpManager.h
//  TrackCheck
//
//  Created by ethome on 2021/1/20.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
NS_ASSUME_NONNULL_BEGIN



 

@protocol TcpManagerDelegate <NSObject>

-(void)testSocket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;

 

-(void)testSocketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;

 

-(void)testSocket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;

-(void)testSocket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag;

@end

@interface TcpManager : NSObject
@property(strong,nonatomic) GCDAsyncSocket *asyncsocket;

@property(nonatomic,strong)id<TcpManagerDelegate>delegate;

+(TcpManager *)Share;

-(BOOL)destroy;

@end



NS_ASSUME_NONNULL_END
