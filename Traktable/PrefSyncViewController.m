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
#import "ITDb.h"
#import "ITSync.h"

@interface PrefSyncViewController()

@end

@implementation PrefSyncViewController

@synthesize collection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    
    return self;
}

- (void) viewWillAppear {
    
    ITApi *api = [ITApi new];
    
    collection.state = [api collection];
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
        
        [ITSync syncTraktExtendedInBackgroundThread];
        
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
    ITSync *sync = [[ITSync alloc] init];
    
    if([api testAccount]) {
        
        dispatch_queue_t queue;
        queue = dispatch_queue_create("traktable.import.queue", NULL);
        
        dispatch_retain(queue);
        
        dispatch_async(queue, ^{
            
            [library importLibrary];
            
            [sync syncTraktExtended];
            
            dispatch_async(queue, ^{
                [ITNotification showNotification:[NSString stringWithFormat:@"iTunes library import done"]];
            });
            
            dispatch_release(queue);
        });
        
    } else {
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
    }
    
    [btn setEnabled:YES];
}

- (IBAction)reset:(id)sender {
    
    ITDb *db = [ITDb new];
    ITLibrary *library = [[ITLibrary alloc] init];
    
    [[NSFileManager defaultManager] removeItemAtPath:[db getDbFilePath] error:nil];
    [library resetDb];
    
    NSString *logPath = @"/tmp/ITDebug.log";
    
    [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
    
    
}

- (IBAction)addToCollection:(id)sender {
    
    NSButton *cb = (NSButton *) sender;
    
    [[NSUserDefaults standardUserDefaults] setBool:cb.state forKey:@"collection"];
}

@end