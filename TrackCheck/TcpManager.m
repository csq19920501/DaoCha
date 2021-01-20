//
//  TcpManager.m
//  TrackCheck
//
//  Created by ethome on 2021/1/20.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "TcpManager.h"

@interface TcpManager() <GCDAsyncSocketDelegate>

 

@end

 

@implementation TcpManager

+(TcpManager *)Share

{

    static TcpManager *manager=nil;

    static dispatch_once_t once;

    dispatch_once(&once, ^{

        manager=[[TcpManager alloc]init];

        manager.asyncsocket=[[GCDAsyncSocket alloc]initWithDelegate:manager delegateQueue:dispatch_get_main_queue()];

        

    });

    return manager;

}

 

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port

{

    if ([self.delegate respondsToSelector:@selector(testSocket:didConnectToHost:port:)]) {

        [self.delegate testSocket:sock didConnectToHost:host port:port];

    }

}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err

{

    if ([self.delegate respondsToSelector:@selector(testSocketDidDisconnect:withError:)]) {

        [self.delegate testSocketDidDisconnect:sock withError:err];

    }

}

 

 

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag

{

    if ([self.delegate respondsToSelector:@selector(testSocket:didReadData:withTag:)]) {

        [self.delegate testSocket:sock didReadData:data withTag:tag];

    }

    

    //    [sock disconnect];

}

 

 

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag

{

    if ([self.delegate respondsToSelector:@selector(testSocket:didWriteDataWithTag:)]) {

        [self.delegate testSocket:sock didWriteDataWithTag:tag];

    }

}

 

 

-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length

{

    NSLog(@"timeout");

    return 0;

}

 

-(BOOL)destroy

{

    [_asyncsocket disconnect];

    return YES;

}

 @end
