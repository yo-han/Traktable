//
//  ITLibrary.h
//  Traktable
//
//  Created by Johan Kuijt on 05-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

@interface ITLibrary : NSObject

@property (nonatomic, retain) iTunesApplication *iTunesBridge;

@property (nonatomic) NSString *dbFilePath;
@property (nonatomic) BOOL firstImport;

- (void)importLibrary;
- (void)syncLibrary;
- (void)syncTrakt;
- (BOOL)dbExists;

- (void)updateTrackCount:(iTunesTrack *)track scrobbled:(BOOL)scrobble;
- (iTunesTrack *)getTrack:(NSString *)persistentID type:(iTunesESpK)videoType;
- (SBElementArray *)getVideos:(iTunesESpK)playlist noCheck:(BOOL)noChecking;

@end
