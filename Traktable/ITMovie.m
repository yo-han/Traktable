//
//  ITMovie.m
//  Traktable
//
//  Created by Johan Kuijt on 04-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITMovie.h"
#import "IMDB.h"
#import "ITUtil.h"

@implementation ITMovie

@synthesize name, playCount, year, duration, persistentID, videoKind, imdbId;
@synthesize movieId, trailer, url, released, genres, image, tmdbId, tagline, overview, poster;
@synthesize timestamp, action;

+(ITMovie *)movieWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack {
    
    ITMovie *movie = [ITMovie new];
    movie.name           = [iTunesTrack name];
    if (!movie.name) return nil;
    movie.playCount      = [iTunesTrack playedCount];
    movie.year           = [iTunesTrack year];
    movie.duration       = (NSInteger)([iTunesTrack duration]/60);
    movie.persistentID   = [iTunesTrack persistentID];
    movie.videoKind      = [iTunesTrack videoKind];
    movie.imdbId      =  [IMDB getImdbIdByTitle:movie.name year:[NSString stringWithFormat:@"%ld",(long)movie.year]];

    return movie;
}

+(ITMovie *)movieWithDatabaseRecord:(NSDictionary *)record {
    
    ITMovie *movie = [ITMovie new];
    
    movie.movieId = [record objectForKey:@"movieId"];
    movie.name = [record objectForKey:@"title"];
    movie.image = [record objectForKey:@"poster"];
    movie.playCount = [record objectForKey:@"traktPlays"];
    movie.year = [[record objectForKey:@"year"] intValue];
    movie.overview = [record objectForKey:@"overview"];
    movie.url = [record objectForKey:@"traktUrl"];
    
    if([record objectForKey:@"timestamp"] != nil) {
        
        movie.timestamp = [record objectForKey:@"timestamp"];
        movie.action = [record objectForKey:@"action"];
        
    } 
    
    return movie;
}

+ (NSDictionary *)traktEntity:(ITMovie *)aMovie batch:(NSArray *)aBatch {
  
    NSDictionary *httpObject;
    NSString *appVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSDate *appBuildDate = [ITUtil appBuildDate];
    
    if (aMovie && aBatch == nil) {
        
        NSDictionary *movie = [NSDictionary dictionaryWithObjectsAndKeys:aMovie.name, @"title", [NSNumber numberWithLong:aMovie.year], @"year", nil];
        httpObject = [NSDictionary dictionaryWithObjectsAndKeys:movie, @"movie", [NSNumber numberWithInt:99], @"progress", appVersion, @"app_version",[appBuildDate descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], @"app_date", nil];

    } else if(aMovie == nil && aBatch != nil){
        
    } else {
        
    }
    
    return httpObject;
}

+ (NSInteger)playCount {
    return self.playCount;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ (%ld)",self.name, self.year];
}

@end
