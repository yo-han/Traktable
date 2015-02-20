//
//  AppDelegate.m
//  Traktable
//
//  Created by Johan Kuijt on 01-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "ProgressWindowController.h"
#import "WebViewController.h"
#import "MASPreferencesWindowController.h"
#import "PrefIndexViewController.h"
#import "PrefSyncViewController.h"
#import "PrefUpdateViewController.h"
#import "ITApi.h"
#import "ITVideo.h"
#import "ITLibrary.h"
#import "ITMovie.h"
#import "ITNotification.h"
#import "ITDb.h"
#import "ITSync.h"
#import "ITConstants.h"
#import <FeedbackReporter/FRFeedbackReporter.h>
#import <OAuth2Client/NXOAuth2.h>
#import <WebKit/WebKit.h>

// Scripting Bridge
#import "iTunes.h"
#import "VLC.h"

@interface AppDelegate()

@property(assign) BOOL showProgressWindow;
@property(assign) BOOL isSyncing;
@property(assign) BOOL showLogin;

@property(strong) MainWindowController *mainWindow;
@property(strong, nonatomic) ProgressWindowController *progressWindow;
@property(strong, nonatomic) WebViewController *webview;

@property(nonatomic, retain) ITApi *api;
@property(nonatomic, retain) ITVideo *video;
@property(nonatomic, retain) ITLibrary *library;
@property(nonatomic, retain) ITSync *sync;

- (IBAction)showLog:(id)sender;
- (IBAction)feedback:(id)sender;
- (IBAction)openTraktProfile:(id)sender;
- (IBAction)displayPreferences:(id)sender;
- (IBAction)showWindow:(id)sender;

@end

@implementation AppDelegate

@synthesize currentlyPlaying, statusItem, statusMenu, showLog, timer;

+ (void)initialize;
{
    ITApi *api = [ITApi new];
    
    [[NXOAuth2AccountStore sharedStore] setClientID:[api apiKey]
                                             secret:[api apiSecret]
                                   authorizationURL:[NSURL URLWithString:@"https://trakt.tv/oauth/authorize"]
                                           tokenURL:[NSURL URLWithString:@"https://api.trakt.tv/oauth/token"]
                                        redirectURL:[NSURL URLWithString:@"traktable://oauth"]
                                     forAccountType:@"Trakt.tv"];
    
    
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    NSArray *pairComponents = [url componentsSeparatedByString:@"="];
    NSString *code = [pairComponents lastObject];
    
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"TraktOAuthCode"];
    
    [self showWindow:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{   
    // Make sure all logging with NSLog is ported to the log file in the compiled version of the app
    [self redirectConsoleLogToDocumentFolder];

    [[FRFeedbackReporter sharedReporter] reportIfCrash];
    
    _api = [ITApi new];
    _video = [[ITVideo alloc] init];
    _library = [[ITLibrary alloc] init];
    _sync = [[ITSync alloc] init];
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(getUrl:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    
    // Register this class as the NotificationCenter delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.sync selector:@selector(updateMovieData:) name:kITMovieNeedsUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.sync selector:@selector(updateTVShowData:) name:kITTVShowNeedsUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.sync selector:@selector(updateEpisodeData:) name:kITTVShowEpisodeNeedsUpdateNotification object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    if(!self.webview)
        _webview = [[WebViewController alloc] initWithWindowNibName:@"WebViewController"];
    
    if(![self.api username] || ![self.api testAccount]) {

        [self.webview.window makeKeyAndOrderFront:self];

        [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"Trakt.tv"
                                       withPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
                                           
                                           [[self.webview.myWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                       }];
        
        [NSApp requestUserAttention:NSInformationalRequest];
        
        return;
        
    } else {
        
        NSLog(@"Startup normal, loggedin.");
       
        [NSTimer scheduledTimerWithTimeInterval:900 target:self selector:@selector(iTunesSourceSaved:) userInfo:nil repeats:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:3600 target:self.api selector:@selector(retryTraktQueue) userInfo:nil repeats:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:86400 target:[ITSync class] selector:@selector(syncTraktExtendedInBackgroundThread) userInfo:nil repeats:YES];
        
        [self showWindow:self];
    }
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesChangedState:) name:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.sourceInfo" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(VLCPlayerStateDidChange) name:@"VLCPlayerStateDidChange" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.sourceSaved" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.sourceInfo" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
}

- (IBAction)showLog:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/ITDebug.log"];
}

- (IBAction)showWindow:(id)sender {
    
    if(!self.mainWindow)
        _mainWindow = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    
    [self.mainWindow.window makeKeyAndOrderFront:self];
    
    [self.webview.window orderOut:nil];
    
    [NSApp activateIgnoringOtherApps:YES];
}

/*
- (void)migrateProgressWindow {
    
    _showProgressWindow = YES;
    _isSyncing = YES;
    
    [self.progressWindow showWindow:self];
    
    [NSApp requestUserAttention:NSInformationalRequest];
}

- (void)showProgressWindow:(NSNotification *)notification {

    if(self.showProgressWindow == NO)
        return;

    //[self.progressWindow.window makeKeyAndOrderFront:self];
    
    if(notification == nil) {
        
        [self.progressWindow.progress setIndeterminate:YES];
        [self.progressWindow.loginView setHidden:NO];
        [self.progressWindow.loginView displayIfNeeded];
        
    } else {
        
        double progress = [[notification.userInfo objectForKey:@"progress"] doubleValue];
        
        [self.progressWindow.loginView setHidden:YES];
        [self.progressWindow.progress setIndeterminate:NO];
        [self.progressWindow.progress setDoubleValue:progress];
        [self.progressWindow.progress setHidden:NO];
        [self.progressWindow.description setHidden:NO];
        
        [self.progressWindow.progress displayIfNeeded];
        [self.progressWindow.description displayIfNeeded];
        [self.progressWindow.bgImage displayIfNeeded];
        [self.progressWindow.loginView displayIfNeeded];
        
        _isSyncing = YES;
        
        if([[notification.userInfo objectForKey:@"type"] isEqualToString:@"movies"]) {
            [self.progressWindow.description setStringValue:@"Syncing movies with Trakt.tv"];
        } else if([[notification.userInfo objectForKey:@"type"] isEqualToString:@"tvshows"]) {
            [self.progressWindow.description setStringValue:@"Syncing TV Shows with Trakt.tv"];
        } else if([[notification.userInfo objectForKey:@"type"] isEqualToString:@"history"]) {

            _showLogin = NO;
            [self.progressWindow.description setStringValue:@"Syncing history with Trakt.tv"];
        }
    }
}

- (void)hideProgressWindow {

    if(self.showLogin == YES)
        return;
    
    [self.progressWindow.window orderOut:nil];
    [self performSelectorOnMainThread:@selector(showWindow:) withObject:self waitUntilDone:YES];
    
    _showProgressWindow = NO;
    _isSyncing = NO;
}
*/

- (IBAction)feedback:(id)sender {
    
    [[FRFeedbackReporter sharedReporter] reportFeedback];
}

- (IBAction)openTraktProfile:(id)sender {
    
    NSString *url = [NSString stringWithFormat:@"http://trakt.tv/user/%@", [_api username]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction)donate:(id)sender {
    
    NSString *url = @"http://derefer.me/?https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=johankuijt%40gmail%2ecom&lc=NL&item_name=Traktable&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
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
    //[statusItem setMenu:statusMenu];
    [statusItem setImage:icon];
    [statusItem setHighlightMode:YES];
    [statusItem setAction:@selector(showWindow:)];
}

- (void)VLCPlayerStateDidChange {
    
    NSLog(@"Go VLC");
    
    [self.video getCurrentlyPlaying:ITPlayerVLC];
}

- (void)iTunesChangedState:(NSNotification*)notification {

    if(![self.api testAccount]) {
        
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
        return;
    }
        
    NSDictionary *newPlayerInfo = [notification userInfo];
    NSString *playerState = [newPlayerInfo objectForKey:@"Player State"];
    
    if ([playerState isEqualToString:@"Playing"]) {
        
        NSLog(@"iTunes started playing");
                
        if (![self.video isVideoPlaying:ITPlayerITunes]) {
         
            [self checkProgress];
            return;
        }
        
        currentlyPlaying = [self.video getCurrentlyPlaying:ITPlayerITunes];
        
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

#pragma mark -- NotificationCenter

// Always show notifications, also when the app is not key
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
