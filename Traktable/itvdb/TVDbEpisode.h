//
//  TVDbEpisode.h
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVDbClient, XMLReader;

@interface TVDbEpisode : NSObject

@property (nonatomic, strong) NSNumber *episodeId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSNumber *seasonNumber;
@property (nonatomic, strong) NSNumber *episodeNumber;
@property (nonatomic, strong) NSString *banner;
@property (nonatomic, strong) NSString *bannerThumbnail;
@property (nonatomic, strong) NSArray *writer;
@property (nonatomic, strong) NSArray *director;
@property (nonatomic, strong) NSArray *gueststars;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic, strong) NSDate *premiereDate;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *showId;

+ (TVDbEpisode *)findById:(NSNumber *)episodeId;
+ (TVDbEpisode *)findByShowId:(NSNumber *)showId seasonNumber:(NSNumber *)seasonNumber episodeNumber:(NSNumber *)episodeNumber;

- (TVDbEpisode *)initWithDictionary:(NSDictionary *)dictionary;

@end