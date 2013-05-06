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
#import "ITNotification.h"

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
    return [NSImage imageNamed:@"sync.png"];
}

-(NSString *)toolbarItemLabel{
    return @"Sync";
}

- (IBAction)sync:(id)sender {
    
    NSLog(@"[manual sync] -- Start iTunes library sync");
    
    [ITNotification showNotification:[NSString stringWithFormat:@"Start iTunes library sync"]];
    
    NSButton *btn = (NSButton *) sender;
    [btn setEnabled:NO];
   
    ITApi *api = [ITApi new];
    ITLibrary *library = [[ITLibrary alloc] init];
    
    if([api testAccount]) {
        [library syncLibrary];
    } else {
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
    }
    
    [btn setEnabled:YES];
    
    [ITNotification showNotification:[NSString stringWithFormat:@"iTunes library sync done"]];
    
    NSLog(@"[/manual sync] -- iTunes library sync done");
}

- (IBAction)import:(id)sender {
    
    [ITNotification showNotification:[NSString stringWithFormat:@"Start iTunes library import"]];
    
    NSButton *btn = (NSButton *) sender;
    [btn setEnabled:NO];
    
    ITApi *api = [ITApi new];
    ITLibrary *library = [[ITLibrary alloc] init];
    
    if([api testAccount]) {
        [library importLibrary];
    } else {
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
    }
    
    [btn setEnabled:YES];
    
    [ITNotification showNotification:[NSString stringWithFormat:@"iTunes library import done"]];

}

- (IBAction)reset:(id)sender {
    
    NSString *appSupportPath = [ITLibrary applicationSupportFolder];
    NSString *dbFilePath = [appSupportPath stringByAppendingPathComponent:@"iTraktor.db"];

    [[NSFileManager defaultManager] removeItemAtPath:dbFilePath error:nil];
    
    NSString *logPath = @"/tmp/ITDebug.log";
    
    [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}

- (IBAction)addToCollection:(id)sender {
    
    NSButton *cb = (NSButton *) sender;
    
    [[NSUserDefaults standardUserDefaults] setBool:cb.state forKey:@"collection"];
}

@end