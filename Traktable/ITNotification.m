//
//  ITNotification.m
//  Traktable
//
//  Created by Johan Kuijt on 28-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITNotification.h"
#import <Growl/Growl.h>

@implementation ITNotification

+ (void)showNotification:(NSString *)description {
    
    BOOL notificationCenterIsAvailable = (NSClassFromString(@"NSUserNotificationCenter")!=nil);
    
    if(!notificationCenterIsAvailable) {
        [self growl:description];
        return;
    }
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    notification.title = @"Traktable";
    notification.informativeText = description;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

+ (void)growl:(NSString *)description {
    
    [GrowlApplicationBridge notifyWithTitle:@"Traktable"
                                description:description
                           notificationName:@"traktableNotification"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

@end
