//
//  ProgressWindowController.m
//  Traktable
//
//  Created by Johan Kuijt on 03-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ProgressWindowController.h"
#import "ITApi.h"
#import "ITSync.h"
#import "ITConstants.h"

@interface ProgressWindowController ()

- (IBAction)login:(id)sender;

@end

@implementation ProgressWindowController

@synthesize checking, username, password, login, loginView, loginStatus, bgImage;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.bgImage setAlphaValue:0.3];
    
    [self.username setTarget:self];
    [self.username setAction:@selector(login:)];
    
    [self.password setTarget:self];
    [self.password setAction:@selector(login:)];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    
    NSTextField *textField = [notification object];
    ITApi *api = [ITApi new];
    
    if(textField.tag == 1)
        [[NSUserDefaults standardUserDefaults] setObject:[self.username stringValue] forKey:@"username"];
    else if(textField.tag == 2)
        [api setPassword:[self.password stringValue]];
}

- (IBAction)login:(id)sender {
    
    ITApi *api = [ITApi new];
    
    [self.checking setHidden:NO];
    [self.checking startAnimation:self];
    
    if(![ITConstants traktReachable]) {
        
        [self.loginStatus setStringValue:@"Can't connect to trakt.tv"];
              
    } else {
    
        if([api testAccount]) {
            
            [self.loginStatus setStringValue:@"Hooray, success!"];
            
            [ITSync syncTraktExtendedInBackgroundThread];
            
            [self.loginView setHidden:YES];
            [self.progress setHidden:NO];
            
        } else {
            [self.loginStatus setStringValue:@"Failed. Wrong password?"];
        }
    }
    
    [self.checking stopAnimation:self];
}

@end
