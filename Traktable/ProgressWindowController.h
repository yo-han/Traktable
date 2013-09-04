//
//  ProgressWindowController.h
//  Traktable
//
//  Created by Johan Kuijt on 03-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProgressWindowController : NSWindowController

@property (nonatomic, assign) IBOutlet NSProgressIndicator *progress;
@property (nonatomic, assign) IBOutlet NSTextField *description;

@end
