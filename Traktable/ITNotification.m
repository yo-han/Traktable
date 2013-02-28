//
//  ITNotification.m
//  Traktable
//
//  Created by Johan Kuijt on 28-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITNotification.h"

@implementation ITNotification

+ (void)showNotification:(NSString *)description {
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    notification.title = @"Traktable";
    notification.informativeText = description;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
