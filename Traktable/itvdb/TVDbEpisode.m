//
//  TVDbEpisode.m
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import "TVDbEpisode.h"
#import "TVDbClient.h"
#import "TVDbImage.h"

#import "XMLReader.h"
#import "NSString+Helper.h"

@interface TVDbEpisode()

+ (NSString *)episodeUrl:(NSNumber *)episodeId;
+ (NSString *)episodeUrlByShowId:(NSNumber *)showId seasonNumber:(NSNumber *)seasonNumber episodeNumber:(NSNumber *)episodeNumber;

@end


@implementation TVDbEpisode

@synthesize episodeId, title, description, seasonNumber, episodeNumber, banner, bannerThumbnail, writer, director, gueststars, imdbId, premiereDate, rating, showId;

#pragma mark - initializers

- (TVDbEpisode *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        self.episodeId       = [NSNumber numberWithInt:[[dictionary retrieveForPath:@"id"] intValue]];
        self.title           = [dictionary retrieveForPath:@"EpisodeName"];
        self.description     = [dictionary retrieveForPath:@"Overview"];
        self.seasonNumber    = [NSNumber numberWithInt:[[dictionary retrieveForPath:@"SeasonNumber"] intValue]];
        self.episodeNumber   = [NSNumber numberWithInt:[[dictionary retrieveForPath:@"EpisodeNumber"] intValue]];
        
        if ([dictionary retrieveForPath:@"filename"])
        {
            TVDbImage *bannerImage = [[TVDbImage alloc] initWithUrl:[dictionary retrieveForPath:@"filename"]];
            
            self.banner            = [bannerImage url];
            self.bannerThumbnail   = [bannerImage thumbnailUrl];
        }
        
        self.writer          = [NSString pipedStringToArray:[dictionary retrieveForPath:@"Writer"]];
        self.director        = [NSString pipedStringToArray:[dictionary retrieveForPath:@"Director"]];
        self.gueststars      = [NSString pipedStringToArray:[dictionary retrieveForPath:@"GuestStars"]];
        self.imdbId          = [dictionary retrieveForPath:@"IMDB_ID"];
        self.premiereDate    = [NSString stringToDate:[dictionary retrieveForPath:@"FirstAired"]];
        self.rating          = [dictionary retrieveForPath:@"Rating"];
        self.showId          = [NSNumber numberWithInt:[[dictionary retrieveForPath:@"seriesid"] intValue]];
    }
    return self;
}

#pragma mark - class methods

+ (TVDbEpisode *)findById:(NSNumber *)episodeId
{
    NSDictionary *episodeDictionary = [[TVDbClient sharedInstance] requestURL:[self episodeUrl:episodeId]];
    return [[TVDbEpisode alloc] initWithDictionary:[episodeDictionary retrieveForPath:@"Data.Episode"]];
}

+ (TVDbEpisode *)findByShowId:(NSNumber *)showId seasonNumber:(NSNumber *)seasonNumber episodeNumber:(NSNumber *)episodeNumber
{
    NSDictionary *episodeDictionary = [[TVDbClient sharedInstance] requestURL:[self episodeUrlByShowId:showId seasonNumber:seasonNumber episodeNumber:episodeNumber]];
    return [[TVDbEpisode alloc] initWithDictionary:[episodeDictionary retrieveForPath:@"Data.Episode"]];
}

#pragma mark - internal methods

+ (NSString *)episodeUrl:(NSNumber *)episodeId
{
    return [[[TVDbClient sharedInstance] apiKey] stringByAppendingString:[NSString stringWithFormat:@"/episodes/%@", episodeId]];
}

+ (NSString *)episodeUrlByShowId:(NSNumber *)showId seasonNumber:(NSNumber *)seasonNumber episodeNumber:(NSNumber *)episodeNumber
{
    return [[[TVDbClient sharedInstance] apiKey] stringByAppendingString:[NSString stringWithFormat:@"/series/%@/default/%@/%@", showId, seasonNumber, episodeNumber]];
}

@end