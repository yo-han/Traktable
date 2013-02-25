//
//  video.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iTunes.h"

@interface ITVideo : NSObject

@property (nonatomic, retain) iTunesApplication *iTunesBridge;

- (id)getCurrentlyPlaying;
- (BOOL)isVideoPlaying;
- (id)getVideoByType:(iTunesTrack *)track type:(iTunesEVdK)aType;

@end
