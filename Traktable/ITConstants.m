//
//  ITConstants.m
//  Traktable
//
//  Created by Johan Kuijt on 06-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITConstants.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation ITConstants

+ (NSString *)applicationSupportFolder {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:
                                                0] : NSTemporaryDirectory();
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return [basePath
            stringByAppendingPathComponent:appName];
}

+ (BOOL)firstBoot {
    
    BOOL firstBoot = [[NSUserDefaults standardUserDefaults] boolForKey:@"traktable.FirstBoot"];

    if (!firstBoot) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"traktable.FirstBoot"];
        
        return YES;
    }
    
    return NO;
}

+(BOOL)traktReachable
{
    SCNetworkReachabilityRef target;
    SCNetworkConnectionFlags flags = 0;
    Boolean ok;

    const char *hostName = [@"trakt.tv" cStringUsingEncoding:NSASCIIStringEncoding];
    
    target = SCNetworkReachabilityCreateWithName(NULL, hostName);
    
    SCNetworkReachabilityGetFlags(target, &flags);
    
    CFRelease(target);
    
    if(flags & kSCNetworkReachabilityFlagsConnectionRequired)
        ok = NO;
    else
        ok = YES;
    
    return ok;
}


@end
