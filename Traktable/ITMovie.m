//
//  ITMovie.m
//  Traktable
//
//  Created by Johan Kuijt on 04-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITMovie.h"
#import "IMDB.h"

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
  
    NSDictionary *params;
    
    if (aMovie && aBatch == nil) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  aMovie.name, @"title",
                  [NSString stringWithFormat:@"%ld", aMovie.year], @"year",
                  [NSDictionary dictionaryWithObjectsAndKeys:
                    aMovie.imdbId, @"imdb_id",
                   nil], @"ids",
                  nil];
        
    } else if(aMovie == nil && aBatch != nil){
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  aBatch, @"movies",
                  nil];
    } else {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  nil];
        
    }
    
    return params;
}

+ (NSInteger)playCount {
    return self.playCount;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ (%ld)",self.name, self.year];
}

@end
