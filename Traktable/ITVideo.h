//
//  video.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iTunes.h"
#import "VLC.h"

typedef NS_ENUM(NSUInteger, ITVideoPlayer) {
    ITPlayerITunes = 0,
    ITPlayerVLC = 1,
    ITPlayerUnknown = NSIntegerMax
};

@interface ITVideo : NSObject

- (id)getCurrentlyPlaying:(ITVideoPlayer)player;
- (BOOL)isVideoPlaying:(ITVideoPlayer)player;
- (id)getITunesVideoByType:(iTunesTrack *)track type:(iTunesEVdK)aType;

@end
