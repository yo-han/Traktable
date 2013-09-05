//
//  ProgressWindowController.h
//  Traktable
//
//  Created by Johan Kuijt on 03-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProgressWindowController : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, assign) IBOutlet NSProgressIndicator *checking;
@property (nonatomic, assign) IBOutlet NSTextField *username;
@property (nonatomic, assign) IBOutlet NSTextField *password;
@property (nonatomic, assign) IBOutlet NSTextField *loginStatus;
@property (nonatomic, assign) IBOutlet NSButton *login;
@property (nonatomic, assign) IBOutlet NSView *loginView;

@property (nonatomic, assign) IBOutlet NSProgressIndicator *progress;
@property (nonatomic, assign) IBOutlet NSTextField *description;

@end
