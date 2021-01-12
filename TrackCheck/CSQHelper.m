//
//  CSQHelper.m
//  TrackCheck
//
//  Created by ethome on 2021/1/12.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CSQHelper.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>
@implementation CSQHelper



+(BOOL)isWIFIConnection

{
    BOOL ret = YES;

    struct ifaddrs * first_ifaddr, * current_ifaddr;

    NSMutableArray* activeInterfaceNames = [[NSMutableArray alloc] init];

    getifaddrs( &first_ifaddr );

    current_ifaddr = first_ifaddr;

    while( current_ifaddr!=NULL )

    {
        if( current_ifaddr->ifa_addr->sa_family==0x02 )

        {
            [activeInterfaceNames addObject:[NSString stringWithFormat:@"%s", current_ifaddr->ifa_name]];

        }

        current_ifaddr = current_ifaddr->ifa_next;

    }

    ret = [activeInterfaceNames containsObject:@"en0"] || [activeInterfaceNames containsObject:@"en1"];

    return ret;

}
@end
