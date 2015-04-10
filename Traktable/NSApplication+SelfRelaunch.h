//
//  NSApplication+SelfRelaunch.h
//  Traktable
//
//  Created by Johan Kuijt on 07-04-15.
//  Copyright (c) 2015 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (Relaunch)

- (void)relaunchAfterDelay:(float)seconds;

@end
