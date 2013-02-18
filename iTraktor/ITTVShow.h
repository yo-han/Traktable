//
//  tvShow.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

@interface ITTVShow : NSObject

@property (nonatomic, strong) NSString *show;
@property (nonatomic, strong) NSString *episodeName;
@property (nonatomic, strong) NSString *persistentID;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic) NSInteger seasonNumber;
@property (nonatomic) NSInteger episodeNumber;
@property (nonatomic) NSInteger playCount;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger duration;
@property (nonatomic) iTunesEVdK videoKind;

+(ITTVShow *)showWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack;

@end
