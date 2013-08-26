//
//  tvShow.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTVShow.h"
#import "ITTVdb.h"

@implementation ITTVShow

@synthesize show, episodeName, seasonNumber, episodeNumber, playCount, year, duration, persistentID, videoKind, imdbId;
@synthesize showId, title, poster;

+(ITTVShow *)showWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack {
    
    ITTVShow *show = [ITTVShow new];
    show.show           = [iTunesTrack show];
    if (!show.show) return nil;
    show.episodeName    = [iTunesTrack name];
    show.seasonNumber   = [iTunesTrack seasonNumber];
    show.episodeNumber  = [iTunesTrack episodeNumber];
    show.playCount      = [iTunesTrack playedCount];
    show.year           = [iTunesTrack year];
    show.duration       = (NSInteger)([iTunesTrack duration]/60);
    show.persistentID   = [iTunesTrack persistentID];
    show.videoKind      = [iTunesTrack videoKind];
    show.imdbId         = [ITTVdb getTVDBId:show.show];

    return show;
}

+(ITTVShow *)showWithDatabaseRecord:(NSDictionary *)record {
    
    ITTVShow *show = [ITTVShow new];
    
    show.showId = [record objectForKey:@"showId"];
    show.title = [record objectForKey:@"title"];
    show.poster = [record objectForKey:@"poster"];
    
    if([record objectForKey:@"success"] != nil) {
        
        show.type = [record objectForKey:@"type"];
        show.comment = [record objectForKey:@"comment"];
        show.success = [record objectForKey:@"success"];
        show.timestamp = [record objectForKey:@"timestamp"];
        
    }
    
    return show;
}

+ (NSInteger)playCount {
    return self.playCount;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (S%02ldE%02ld)",self.show, self.episodeName, self.seasonNumber, self.episodeNumber];
}

@end
