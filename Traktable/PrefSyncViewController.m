//
//  PrefSyncViewController.m
//  Traktable
//
//  Created by Johan Kuijt on 27-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "PrefSyncViewController.h"
#import "ITLibrary.h"
#import "ITApi.h"

@interface PrefSyncViewController()

@end

@implementation PrefSyncViewController

@synthesize testButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    
    return self;
}

- (void) viewWillAppear {
    
}

-(NSString *)identifier{
    return @"Sync";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

-(NSString *)toolbarItemLabel{
    return @"Sync";
}

- (IBAction)sync:(id)sender {
    
    ITApi *api = [ITApi new];
    ITLibrary *library = [[ITLibrary alloc] init];
    
    if([api testAccount]) {
        [library syncLibrary];
    } else {
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
    }
}

- (IBAction)import:(id)sender {
    
    ITApi *api = [ITApi new];
    ITLibrary *library = [[ITLibrary alloc] init];
    
    if([api testAccount]) {
        [library importLibrary];
    } else {
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
    }
}
@end