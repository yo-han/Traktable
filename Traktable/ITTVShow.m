//
//  tvShow.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTVShow.h"
#import "ITTVdb.h"
#import "ITUtil.h"

@implementation ITTVShow

@synthesize show, episodeName, seasonNumber, episodeNumber, playCount, year, duration, persistentID, videoKind, imdbId;
@synthesize showId, title, poster, screen, action, url;

+(ITTVShow *)showWithCurrentITunesTrack:(iTunesTrack *)iTunesTrack {
    
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
    show.episodeName = [record objectForKey:@"episodeTitle"];
    show.poster = [record objectForKey:@"poster"];
    show.screen = [record objectForKey:@"screen"];
    show.seasonNumber = [[record objectForKey:@"season"] intValue];
    show.episodeNumber = [[record objectForKey:@"episode"] intValue];
    show.url = [record objectForKey:@"traktUrl"];
    show.year = [[record objectForKey:@"year"] intValue];
    
    if([record objectForKey:@"timestamp"] != nil) {
        
        show.action = [record objectForKey:@"action"];
        show.timestamp = [record objectForKey:@"timestamp"];
        
    }
    
    return show;
}

+ (NSDictionary *)traktEntity:(ITTVShow *)aShow batch:(NSArray *)aBatch {
    
    NSDictionary *httpObject;
    
    NSString *appVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSDate *appBuildDate = [ITUtil appBuildDate];

    if (aShow && aBatch == nil) {
        
        NSDictionary *show = [NSDictionary dictionaryWithObjectsAndKeys:aShow.show, @"title", nil];
        NSDictionary *episode = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:aShow.seasonNumber], @"season", [NSNumber numberWithLong:aShow.episodeNumber], @"number", nil];
        httpObject = [NSDictionary dictionaryWithObjectsAndKeys:show, @"show", episode, @"episode", [NSNumber numberWithInt:99], @"progress", appVersion, @"app_version",[appBuildDate descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], @"app_date", nil];
        
    } else if(aShow == nil && aBatch != nil){
        
    } else {
        
    }
    
    return httpObject;
}

+ (NSInteger)playCount {
    return self.playCount;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (S%02ldE%02ld)",self.show, self.episodeName, self.seasonNumber, self.episodeNumber];
}

@end
