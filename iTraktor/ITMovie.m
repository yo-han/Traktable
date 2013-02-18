//
//  ITMovie.m
//  iTraktor
//
//  Created by Johan Kuijt on 04-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITMovie.h"
#import "IMDB.h"

@implementation ITMovie

@synthesize name, playCount, year, duration, persistentID, videoKind, imdbId;

+(ITMovie *)movieWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack {
    
    ITMovie *movie = [ITMovie new];
    movie.name           = [iTunesTrack name];
    if (!movie.name) return nil;
    movie.playCount      = [iTunesTrack playedCount];
    movie.year           = [iTunesTrack year];
    movie.duration       = (NSInteger)([iTunesTrack duration]/60);
    movie.persistentID   = [iTunesTrack persistentID];
    movie.videoKind      = [iTunesTrack videoKind];
    movie.imdbId      =  [IMDB getImdbIdByTitle:movie.name year:[[NSNumber numberWithInt:movie.year] stringValue]];
    
    return movie;
}

+ (NSInteger)playCount {
    return self.playCount;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ (%ld)",self.name, self.year];
}

@end
