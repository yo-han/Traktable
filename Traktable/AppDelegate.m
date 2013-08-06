//
//  AppDelegate.m
//  Traktable
//
//  Created by Johan Kuijt on 01-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "MASPreferencesWindowController.h"
#import "PrefIndexViewController.h"
#import "PrefSyncViewController.h"
#import "PrefUpdateViewController.h"
#import "iTunes.h"
#import "ITApi.h"
#import "ITVideo.h"
#import "ITLibrary.h"
#import "ITMovie.h"
#import "ITNotification.h"
#import "ITConstants.h"

@interface AppDelegate()

- (IBAction)showLog:(id)sender;
- (IBAction)feedback:(id)sender;
- (IBAction)openHistory:(id)sender;
- (IBAction)displayPreferences:(id)sender;
- (IBAction)showWindow:(id)sender;

@property(strong) MainWindowController *mainWindow;

@end

@implementation AppDelegate

@synthesize currentlyPlaying, statusItem, statusMenu, showLog, timer;
@synthesize api=_api;
@synthesize video=_video;
@synthesize library=_library;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Make sure all logging with NSLog is ported to the log file in the compiled version of the app
    [self redirectConsoleLogToDocumentFolder];
    
    // Register this class as the NotificationCenter delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    _api = [ITApi new];
    _video = [[ITVideo alloc] init];
    _library = [[ITLibrary alloc] init];
    
    NSString *dbFilePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"REPLACE INTO imdb (movie, imdbId) VALUES (?,?)" withArgumentsInArray:[NSArray arrayWithObjects:@"aaabbb",@"ccc", nil]];
    }];
    
    [self.library syncTrakt];
    
    return;
    if(![self.api testAccount]) {
        
        [self noAuthAlert];
        [self displayPreferences:self];
        
        return;
        
    } else {
        
        NSLog(@"Startup normal, loggedin.");
    }
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesChangedState:) name:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.sourceSaved" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
}

- (IBAction)showLog:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/ITDebug.log"];
}

- (IBAction)showWindow:(id)sender {
    
    if(!self.mainWindow)
        _mainWindow = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    
    [self.mainWindow.window makeKeyAndOrderFront:self];
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)feedback:(id)sender {
    
    NSString *encodedSubject = [NSString stringWithFormat:@"SUBJECT=%@", [@"Traktable feedback" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSString *encodedBody = [NSString stringWithFormat:@"BODY=%@", [@"Your feedback here..." stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSString *encodedTo = [@"traktable@w3f.nl" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *encodedURLString = [NSString stringWithFormat:@"mailto:%@?%@&%@", encodedTo, encodedSubject, encodedBody];
    NSURL *mailtoURL = [NSURL URLWithString:encodedURLString];
    [[NSWorkspace sharedWorkspace] openURL:mailtoURL];
}

- (void) redirectConsoleLogToDocumentFolder
{
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    
    if ([currentPath rangeOfString:@"Debug"].location == NSNotFound) {

        NSString *logPath = @"/tmp/ITDebug.log";
        freopen([logPath fileSystemRepresentation],"a+",stderr);
    }
}

-(void)awakeFromNib{
    
    NSImage *icon = [NSImage imageNamed:@"menuicon.png"];
    [icon setSize:CGSizeMake(18, 18)];
    
    [showLog setKeyEquivalentModifierMask:NSAlternateKeyMask];
    [showLog setAlternate:YES];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:icon];
    [statusItem setHighlightMode:YES];
}

- (void)iTunesChangedState:(NSNotification*)notification {

    if(![self.api testAccount]) {
        
        [self noAuthAlert];
        NSLog(@"No auth, no sync");
        return;
    }
        
    NSDictionary *newPlayerInfo = [notification userInfo];
    NSString *playerState = [newPlayerInfo objectForKey:@"Player State"];
    
    if ([playerState isEqualToString:@"Playing"]) {
        
        NSLog(@"iTunes started playing");
                
        if (![self.video isVideoPlaying]) {
         
            [self checkProgress];
            return;
        }
        
        currentlyPlaying = [self.video getCurrentlyPlaying];
        
        [self watching];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(watching) userInfo:nil repeats:YES];
        
    } else if ([playerState isEqualToString:@"Stopped"]) {
        
        NSLog(@"iTunes stopped playing");
        
        [timer invalidate];
        if (currentlyPlaying) [self checkProgress];
        
    } else if ([playerState isEqualToString:@"Paused"]) {
        NSLog(@"iTunes paused playing");
        
        [timer invalidate];
        if (currentlyPlaying) [self checkProgress];
    }
}

-(void)iTunesSourceSaved:(NSNotification*)notification {
    
    if([self.api testAccount]) {
        [self.library syncLibrary];
    } else {
        [self noAuthAlert];
        NSLog(@"No auth, no sync");
    }
}

-(void)watching {
    
    [self.api updateState:currentlyPlaying state:@"watching"];
    
    [ITNotification showNotification:[NSString stringWithFormat:@"Watching: %@", currentlyPlaying]];
}

-(void)checkProgress {
    
    if(currentlyPlaying == nil)
        return;
    
    iTunesEVdK videoType = [currentlyPlaying videoKind];
    iTunesESpK playlist;
    
    if(videoType == iTunesEVdKMovie) {
        playlist = iTunesESpKMovies;
        currentlyPlaying = (ITMovie *) currentlyPlaying;
    } else {
        playlist = iTunesESpKTVShows;
        currentlyPlaying = (ITTVShow *) currentlyPlaying;
    }

    [currentlyPlaying playCount];
    
    if ([currentlyPlaying playCount] < [[self.library getTrack:[currentlyPlaying persistentID] type:playlist] playedCount]) {
        
        [self.api updateState:currentlyPlaying state:@"scrobble"];
        [self.library updateTrackCount:[self.library getTrack:[currentlyPlaying persistentID] type:playlist] scrobbled:YES];
       
    } else {
        
        [self.api updateState:currentlyPlaying state:@"cancelwatching"];
        
        [ITNotification showNotification:[NSString stringWithFormat:@"Canceled watching: %@", currentlyPlaying]];
    }

    currentlyPlaying = nil;
}

- (IBAction)displayPreferences:(id)sender {
    
    if(_preferencesWindow == nil){
        NSViewController *prefIndexViewController = [[PrefIndexViewController alloc] initWithNibName:@"PrefIndexViewController" bundle:[NSBundle mainBundle]];
        NSViewController *prefSyncViewController = [[PrefSyncViewController alloc] initWithNibName:@"PrefSyncViewController" bundle:[NSBundle mainBundle]];
        NSViewController *prefUpdateViewController = [[PrefUpdateViewController alloc] initWithNibName:@"PrefUpdateViewController" bundle:[NSBundle mainBundle]];
        NSArray *views = [NSArray arrayWithObjects:prefIndexViewController, prefSyncViewController, prefUpdateViewController, nil];
        NSString *title = NSLocalizedString(@"Preferences", @"With the letter P of Preferences...");
        _preferencesWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:views title:title];
    }
    [self.preferencesWindow showWindow:self];
    //[self.preferencesWindow.window setLevel: NSNormalWindowLevel];
    [self.preferencesWindow.window setLevel: NSStatusWindowLevel];
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)noAuthAlert {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Can't scrobble right now"];
    [alert setInformativeText:@"You didn't submit your authentication data yet or it is incorrect. Without the right username and password it's pretty hard to scrobble..."];
    [alert runModal];
}

- (IBAction)openHistory:(id)sender {
    
    NSString *url = [NSString stringWithFormat:@"http://trakt.tv/user/%@/history", [_api username]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

#pragma mark -- NotificationCenter

// Always show notifications, also when the app is not key
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}
@end
