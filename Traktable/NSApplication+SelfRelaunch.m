//
//  NSApplication+SelfRelaunch.m
//  Traktable
//
//  Created by Johan Kuijt on 07-04-15.
//  Copyright (c) 2015 Mustacherious. All rights reserved.
//

#import "NSApplication+SelfRelaunch.h"

@implementation NSApplication (Relaunch)

- (void)relaunchAfterDelay:(float)seconds
{
    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    
    NSLog(@"Relaunch");
    
    [self terminate:nil];
}

@end