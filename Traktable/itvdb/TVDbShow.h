//
//  TVDbShow.h
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVDbClient, TVDbEpisode, TVDbImage, XMLReader;

@interface TVDbShow : NSObject

// basic properties of a show

@property (nonatomic, strong) NSNumber *showId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *banner;
@property (nonatomic, strong) NSString *bannerThumbnail;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic, strong) NSDate *premiereDate;

// extra properties of a show

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *genre;
@property (nonatomic, strong) NSArray *actors;
@property (nonatomic, strong) NSString *poster;
@property (nonatomic, strong) NSString *posterThumbnail;
@property (nonatomic, strong) NSString *airDay;
@property (nonatomic, strong) NSString *airTime;
@property (nonatomic, strong) NSString *runtime;
@property (nonatomic, strong) NSString *network;
@property (nonatomic, strong) NSString *contentRating;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSMutableArray *episodes;

+ (NSMutableArray *)findByName:(NSString *)name;
+ (TVDbShow *)findById:(NSNumber *)showId;

- (TVDbShow *)initWithDictionary:(NSDictionary *)dictionary;

@end