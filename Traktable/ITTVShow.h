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
@property (nonatomic, strong) NSString *poster;
@property (nonatomic, strong) NSString *screen;
@property (nonatomic, strong) NSString *url;

// History items
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *timestamp;

+(ITTVShow *)showWithCurrentITunesTrack:(iTunesTrack *)iTunesTrack;
+(ITTVShow *)showWithDatabaseRecord:(NSDictionary *)record;
+(NSDictionary *)traktEntity:(ITTVShow *)aShow batch:(NSArray *)aBatch;

@end
