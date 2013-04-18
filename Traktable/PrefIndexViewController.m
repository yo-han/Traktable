//
//  PrefIndexViewController.m
//  Traktable
//
//  Created by Johan Kuijt on 12-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "PrefIndexViewController.h"

@interface PrefIndexViewController ()

@end

@implementation PrefIndexViewController

@synthesize name, password, statusLabel, testButton;
@synthesize api=_api;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
       
        _api = [[ITApi alloc] init];
    }
    
    return self;
}

- (void) viewWillAppear {
    
    NSString *username = [self.api username];
    NSString *pwd = [self.api password];
    
    [name setDelegate:self];
    [password setDelegate:self];
    
    if(username != nil)
        [name setStringValue:username];
    
    if(pwd != nil)
        [password setStringValue:pwd];
}

-(NSString *)identifier{
    return @"Account";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNameUser];
}

-(NSString *)toolbarItemLabel{
    return @"Account";
}

- (void)controlTextDidChange:(NSNotification *)notification {
    
    NSTextField *textField = [notification object];
    
    if(textField.tag == 1)
        [[NSUserDefaults standardUserDefaults] setObject:[name stringValue] forKey:@"username"];
    else if(textField.tag == 2)
        [self.api setPassword:[password stringValue]];
}

- (IBAction)testAuth:(id)sender {
    
    if([self.api testAccount]) {
        [statusLabel setStringValue:@"Hooray, success!"];
    } else {
        [statusLabel setStringValue:@"Failed"];
    }
}
@end