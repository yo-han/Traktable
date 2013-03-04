//
//  AppDelegate.h
//  Traktable
//
//  Created by Johan Kuijt on 01-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CFNetwork/CFNetwork.h>
#import <sys/socket.h>
#import <netinet/in.h>

@class ITApi, ITVideo, ITLibrary;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSUserNotificationCenterDelegate>

@property (strong) NSWindowController *preferencesWindow;
@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet NSMenuItem *showLog;
@property (strong) NSStatusItem * statusItem;

@property(nonatomic, retain) id currentlyPlaying;
@property(nonatomic, retain) ITApi *api;
@property(nonatomic, retain) ITVideo *video;
@property(nonatomic, retain) ITLibrary *library;
@property(nonatomic, retain) NSTimer *timer;

@end
