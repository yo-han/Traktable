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

// Db only
@property (nonatomic, strong) NSNumber *showId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSImage *poster;

// History items
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *success;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *timestamp;

+(ITTVShow *)showWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack;
+(ITTVShow *)showWithDatabaseRecord:(NSDictionary *)record;

@end
