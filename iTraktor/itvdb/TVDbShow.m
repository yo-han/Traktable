//
//  TVDbShow.m
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import "TVDbShow.h"
#import "TVDbClient.h"
#import "TVDbEpisode.h"
#import "TVDbImage.h"

#import "XMLReader.h"
#import "NSString+Helper.h"

@interface TVDbShow()

+ (void)buildShowWithDictionary:(NSDictionary *)dictionary reference:(NSMutableArray **)reference;
+ (NSString *)searchTermUrl:(NSString *)term;
+ (NSString *)searchTerm:(NSString *)term;
+ (NSString *)showUrl:(NSNumber *)showId;

- (void)buildEpisodesWithDictionary:(NSDictionary *)dictionary;
- (void)buildEpisodeWithDictionary:(NSDictionary *)dictionary reference:(NSMutableArray **)reference;

@end


@implementation TVDbShow

@synthesize showId, title, description, banner, bannerThumbnail, imdbId, premiereDate;
@synthesize status, genre, actors, poster, posterThumbnail, airDay, airTime, runtime, network, contentRating, rating, episodes;

#pragma mark - initializers

- (TVDbShow *)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        NSDictionary *showDictionary = dictionary;
        if ([dictionary retrieveForPath:@"Series"])
        {
            showDictionary = [dictionary retrieveForPath:@"Series"];
        }

        // properties retrieved by a basic search request

        self.showId          = [NSNumber numberWithInt:[[showDictionary retrieveForPath:@"id"] intValue]];
        self.title           = [showDictionary retrieveForPath:@"SeriesName"];
        self.description     = [showDictionary retrieveForPath:@"Overview"];
        self.imdbId          = [showDictionary retrieveForPath:@"IMDB_ID"];
        self.premiereDate    = [NSString stringToDate:[showDictionary retrieveForPath:@"FirstAired"]];

        if ([showDictionary retrieveForPath:@"banner"])
        {
            TVDbImage *bannerImage = [[TVDbImage alloc] initWithUrl:[showDictionary retrieveForPath:@"banner"]];

            self.banner          = [bannerImage url];
            self.bannerThumbnail = [bannerImage thumbnailUrl];
        }

        // properties retrieved by a detailed series search request

        self.status          = [showDictionary retrieveForPath:@"Status"];
        self.genre           = [NSString pipedStringToArray:[showDictionary retrieveForPath:@"Genre"]];
        self.actors          = [NSString pipedStringToArray:[showDictionary retrieveForPath:@"Actors"]];
        self.airDay          = [showDictionary retrieveForPath:@"Airs_DayOfWeek"];
        self.airTime         = [showDictionary retrieveForPath:@"Airs_Time"];
        self.runtime         = [showDictionary retrieveForPath:@"Runtime"];
        self.network         = [showDictionary retrieveForPath:@"Network"];
        self.contentRating   = [showDictionary retrieveForPath:@"ContentRating"];
        self.rating          = [showDictionary retrieveForPath:@"Rating"];

        if ([showDictionary retrieveForPath:@"poster"])
        {
            TVDbImage *posterImage = [[TVDbImage alloc] initWithUrl:[showDictionary retrieveForPath:@"poster"]];

            self.poster          = [posterImage url];
            self.posterThumbnail = [posterImage thumbnailUrl];
        }

        if ([dictionary retrieveForPath:@"Episode"])
        {
            [self buildEpisodesWithDictionary:[dictionary retrieveForPath:@"Episode"]];
        }
    }
    return self;
}

# pragma mark - class methods

+ (NSMutableArray *)findByName:(NSString *)name
{
    id response = [[[TVDbClient sharedInstance] requestURL:[self searchTermUrl:name]] retrieveForPath:@"Data.Series"];

    NSMutableArray *shows = [NSMutableArray array];
    if ([response isKindOfClass:[NSDictionary class]])
    {
        [self buildShowWithDictionary:response reference:&shows];
    }
    if ([response isKindOfClass:[NSArray class]])
    {
        for (id showDictionary in response)
        {
            [self buildShowWithDictionary:showDictionary reference:&shows];
        }
    }
    return shows;
}

+ (TVDbShow *)findById:(NSNumber *)showId
{
    NSDictionary *responseDictionary = [[TVDbClient sharedInstance] requestURL:[self showUrl:showId]];
    return [[TVDbShow alloc] initWithDictionary:[responseDictionary retrieveForPath:@"Data.Series"]];
}

# pragma mark - internal methods

+ (void)buildShowWithDictionary:(NSDictionary *)dictionary reference:(NSMutableArray **)reference
{
    TVDbShow *show = [[TVDbShow alloc] initWithDictionary:dictionary];
    [*reference addObject:show];
}

+ (NSString *)searchTermUrl:(NSString *)term
{
    return [NSString stringWithFormat: @"GetSeries.php?seriesname=%@&language=%@", [self searchTerm:term], [[TVDbClient sharedInstance] language]];
}

+ (NSString *)searchTerm:(NSString *)term
{
    return [term stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

+ (NSString *)showUrl:(NSNumber *)showId
{
    return [[[TVDbClient sharedInstance] apiKey] stringByAppendingString:[NSString stringWithFormat:@"/series/%@/all/", showId]];
}

- (void)buildEpisodesWithDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *showEpisodes = [NSMutableArray array];
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        [self buildEpisodeWithDictionary:dictionary reference:&showEpisodes];
    }
    if ([dictionary isKindOfClass:[NSArray class]])
    {
        for (id episodeDictionary in dictionary)
        {
            [self buildEpisodeWithDictionary:episodeDictionary reference:&showEpisodes];
        }
    }
    self.episodes = showEpisodes;
}

- (void)buildEpisodeWithDictionary:(NSDictionary *)dictionary reference:(NSMutableArray **)reference
{
    TVDbEpisode *episode = [[TVDbEpisode alloc] initWithDictionary:dictionary];
    [*reference addObject:episode];
}

@end
