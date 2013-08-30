//
//  ITMovie.h
//  Traktable
//
//  Created by Johan Kuijt on 04-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

@interface ITMovie : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *persistentID;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic) NSInteger playCount;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger duration;
@property (nonatomic) iTunesEVdK videoKind;

// Db only
@property (nonatomic, strong) NSNumber *movieId;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *trailer;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSArray *genres;
@property (nonatomic) NSInteger released;
@property (nonatomic) NSInteger tmdbId;
@property (nonatomic, strong) NSImage *poster;

// History items
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *timestamp;

+(ITMovie *)movieWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack;
+(ITMovie *)movieWithDatabaseRecord:(NSDictionary *)record;

@end
