//
//  AppDelegate.m
//  Traktable
//
//  Created by Johan Kuijt on 01-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "WebViewController.h"
#import "ITApi.h"
#import "ITVideo.h"
#import "ITLibrary.h"
#import "ITMovie.h"
#import "ITNotification.h"
#import "ITDb.h"
#import "ITSync.h"
#import "ITConfig.h"
#import "ITTrakt.h"
#import "ITConstants.h"
#import "NSApplication+SelfRelaunch.h"
#import <FeedbackReporter/FRFeedbackReporter.h>
#import <OAuth2Client/NXOAuth2.h>
#import <WebKit/WebKit.h>

// Scripting Bridge
#import "iTunes.h"
#import "VLC.h"

@interface AppDelegate()

@property(strong) MainWindowController *mainWindow;
@property(strong, nonatomic) WebViewController *webview;

@property(nonatomic, retain) ITApi *api;
@property(nonatomic, retain) ITVideo *video;
@property(nonatomic, retain) ITLibrary *library;
@property(nonatomic, retain) ITSync *sync;
@property(nonatomic, retain) ITTrakt *traktClient;
@property(nonatomic, retain) ITConfig *config;

- (IBAction)showLog:(id)sender;
- (IBAction)feedback:(id)sender;
- (IBAction)openTraktProfile:(id)sender;
- (IBAction)showWindow:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)reset:(id)sender;

@end

@implementation AppDelegate

@synthesize currentlyPlaying, statusItem, statusMenu, showLog;

+ (void)initialize;
{
    ITConfig *config = [ITConfig sharedObject];
    
    [[NXOAuth2AccountStore sharedStore] setClientID:[config apiKey]
                                             secret:[config apiSecret]
                                   authorizationURL:[NSURL URLWithString:@"https://trakt.tv/oauth/authorize"]
                                           tokenURL:[NSURL URLWithString:@"https://api.trakt.tv/oauth/token"]
                                        redirectURL:[NSURL URLWithString:@"traktable://oauth"]
                                     forAccountType:@"Trakt.tv"];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {

    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
  
    NSLog(@"Renew OAuth");
    
    NSArray *pairComponents = [url componentsSeparatedByString:@"="];
    NSString *code = [pairComponents lastObject];
    NSLog(@"%@", code);
    [self.config setOAuthCode:code];
    [self.traktClient traktUserAuthenticated];

    [self showWindow:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   
    // Make sure all logging with NSLog is ported to the log file in the compiled version of the app
    [self redirectConsoleLogToDocumentFolder];

    //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //return;

    _api = [ITApi new];
    _video = [[ITVideo alloc] init];
    _library = [[ITLibrary alloc] init];
    _sync = [[ITSync alloc] init];
    
    _traktClient = [ITTrakt sharedClient];
    _config = [ITConfig sharedObject];
     NSLog(@"%@", [_config OAuthCode]);
    [[FRFeedbackReporter sharedReporter] reportIfCrash];
    
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(getUrl:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    
    // Register this class as the NotificationCenter delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    
    if(!self.webview)
        _webview = [[WebViewController alloc] initWithWindowNibName:@"WebViewController"];
    
    if([self.traktClient traktUserAuthenticated] == NO) {
        NSLog(@"no");
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
        
        [NSTimer scheduledTimerWithTimeInterval:86400 target:self.sync selector:@selector(syncTraktHistoryInBackgroundThread) userInfo:nil repeats:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:3600 target:self.sync selector:@selector(syncTraktHistoryExtendedInBackgroundThread) userInfo:nil repeats:YES];
        
        [self showWindow:self];
    }
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesChangedState:) name:@"com.apple.iTunes.playerInfo" object:@"com.apple.iTunes.player" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.sourceInfo" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(VLCPlayerStateDidChange) name:@"VLCPlayerStateDidChange" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.sourceSaved" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(iTunesSourceSaved:) name:@"com.apple.iTunes.libraryChanged" object:@"com.apple.iTunes.sources" suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
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
     NSLog(@"%@", [_config OAuthCode]);
    //if([ITConstants firstBoot] == YES) {
        NSLog(@"First sync");
        [self.sync syncTraktHistoryInBackgroundThread];
        [self.sync syncTraktHistoryExtendedInBackgroundThread];
    //}
}

- (IBAction)feedback:(id)sender {
    
    [[FRFeedbackReporter sharedReporter] reportFeedback];
}

- (IBAction)openTraktProfile:(id)sender {
    
    NSLog(@"Need to fix this");
    //NSString *url = [NSString stringWithFormat:@"http://trakt.tv/user/%@", [_api username]];
    //[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction)donate:(id)sender {
    
    NSString *url = @"http://derefer.me/?https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=johankuijt%40gmail%2ecom&lc=NL&item_name=Traktable&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction)sync:(id)sender {
 
    [self iTunesSourceSaved:nil];
}

- (IBAction)reset:(id)sender {
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    return;
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
    
    if([self.traktClient traktUserAuthenticated] == NO) {
        
        //[self noAuthAlert];
        NSLog(@"No auth, no sync");
        return;
    }
        
    NSDictionary *newPlayerInfo = [notification userInfo];
    NSString *playerState = [newPlayerInfo objectForKey:@"Player State"];

    if ([playerState isEqualToString:@"Playing"]) {
        
        NSLog(@"iTunes started playing");
        
        [self checkProgress:ITPlayerStart];
       
        currentlyPlaying = [self.video getCurrentlyPlaying:ITPlayerITunes];
        
    } else if ([playerState isEqualToString:@"Stopped"]) {
        
        NSLog(@"iTunes stopped playing");
        
        if (currentlyPlaying) [self checkProgress:ITPlayerStopped];
        
    } else if ([playerState isEqualToString:@"Paused"]) {
        
        NSLog(@"iTunes paused playing");
        
        if (currentlyPlaying) [self checkProgress:ITPlayerPaused];
    }
}

-(void)iTunesSourceSaved:(NSNotification*)notification {
   
    if([self.traktClient traktUserAuthenticated] == YES) {
        
        [self.library performSelectorInBackground:@selector(syncLibrary) withObject:nil];

    } else {

        NSLog(@"No auth, no sync");
    }
}

-(void)checkProgress:(ITVideoPlayerState)playerState {
    
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
    
    [self.api updateState:currentlyPlaying state:playerState];
    
    if (playerState == ITPlayerStopped && [currentlyPlaying playCount] < [[self.library getTrack:[currentlyPlaying persistentID] type:playlist] playedCount])
        [self.library updateTrackCount:[self.library getTrack:[currentlyPlaying persistentID] type:playlist] scrobbled:YES];
       
    currentlyPlaying = nil;
}

#pragma mark -- NotificationCenter

// Always show notifications, also when the app is not key
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
