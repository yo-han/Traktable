//
//  ITSync.m
//  Traktable
//
//  Created by Johan Kuijt on 26-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITSync.h"
#import "ITApi.h"
#import "ITDb.h"
#import "ITMoviePoster.h"
#import "ITTVShowPoster.h"
#import "ITConstants.h"
#import "ITTrakt.h"
#import "ITUtil.h"

@interface ITSync()

@property dispatch_queue_t queue;
@property BOOL extended;

@end

@implementation ITSync

- (id)init {
    
    self = [super init];
	if (self) {
        
        _queue = dispatch_queue_create("traktable.sync.queue", NULL);
        _extended = NO;
    }
    
    return self;
}

- (void)getMoviePoster:(NSNumber *)movieId poster:(NSString *)url {
    
    ITMoviePoster *poster = [ITMoviePoster new];
    
    [poster poster:movieId withUrl:url size:ITMoviePosterSizeSmall];
    [poster poster:movieId withUrl:url size:ITMoviePosterSizeMedium];
    
    // NOTE: No originals till we really need it. The image cache becomes very large very quicly with all these big images.
    //[poster poster:movieId withUrl:url size:ITMoviePosterSizeOriginal];
}

- (void)getTVShowPoster:(NSNumber *)showId poster:(NSString *)url {
    
    ITTVShowPoster *poster = [ITTVShowPoster new];
    
    [poster poster:showId withUrl:url size:ITTVShowPosterSizeSmall];
    [poster poster:showId withUrl:url size:ITTVShowPosterSizeMedium];
    
    // NOTE: No originals till we really need it. The image cache becomes very large very quicly with all these big images.
    //[poster poster:showId withUrl:url size:ITTVShowPosterSizeOriginal];
}

- (void)syncTraktHistoryInBackgroundThread {
    
    dispatch_async(self.queue, ^{ [self syncMovieHistory]; });
    dispatch_async(self.queue, ^{ [self syncTVShowHistory]; });
}

- (void)syncTVShowHistory {
    
    ITTrakt *traktClient = [ITTrakt sharedClient];
    [traktClient GET:kITTraktSyncWatchedShowsUrl withParameters:nil completionHandler:^(id response, NSError *err) {
        
        if(![response isKindOfClass:[NSArray class]]) {
            
            NSLog(@"Response is not an NSArray: %@", err);
            return;
        }
        
        NSDictionary *argsDict = [NSDictionary dictionary];
        NSString *qry;
        
        ITDb *db = [ITDb new];
       
        for(NSDictionary *item in response) {
            
            NSDictionary *show = [item objectForKey:@"show"];
            NSDictionary *ids = [show objectForKey:@"ids"];
            NSArray *seasons = [item objectForKey:@"seasons"];
            
            for(NSDictionary *season in seasons) {
                
                NSArray *episodes = [season objectForKey:@"episodes"];

                for(NSDictionary *episode in episodes) {
                    
                    argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [ITUtil md5HexDigest:[NSString stringWithFormat:@"%@%@", [ids objectForKey:@"trakt"], [episode objectForKey:@"last_watched_at"]]], @"uid",
                                [ids objectForKey:@"tmdb"], @"tmdb_id",
                                [ids objectForKey:@"imdb"], @"imdb_id",
                                [episode objectForKey:@"number"], @"episode",
                                [season objectForKey:@"number"], @"season",
                                @"show", @"type",
                                @"history sync", @"action",
                                [episode objectForKey:@"last_watched_at"], @"timestamp",
                                nil];
            
                    qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
                    [db executeUpdateUsingQueue:qry arguments:argsDict];
                    
                    argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [ids objectForKey:@"tvdb"], @"showTvdb_id",
                                [ids objectForKey:@"imdb"], @"showImdb_id",
                                [ids objectForKey:@"trakt"], @"trakt_id",
                                [episode objectForKey:@"number"], @"episode",
                                [season objectForKey:@"number"], @"season",
                                nil];
                    
                    qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"episodes"];
                    [db executeUpdateUsingQueue:qry arguments:argsDict];
                }
            }
            
            argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [ids objectForKey:@"tvdb"], @"tvdb_id",
                        [ids objectForKey:@"imdb"], @"imdb_id",
                        [ids objectForKey:@"tvrage"], @"tvrage_id",
                        [ids objectForKey:@"trakt"], @"trakt_id",
                        @"0", @"extended",
                        [show objectForKey:@"year"], @"year",
                        [show objectForKey:@"title"], @"title",
                        nil];
            
            qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"tvshows"];
            [db executeUpdateUsingQueue:qry arguments:argsDict];
        }
    }];
}

- (void)syncMovieHistory {
    
    ITTrakt *traktClient = [ITTrakt sharedClient];
    [traktClient GET:kITTraktSyncWatchedMoviesUrl withParameters:nil completionHandler:^(id response, NSError *err) {
        
        if(![response isKindOfClass:[NSArray class]]) {
            
            NSLog(@"Response is not an NSArray: %@", err);
            return;
        }
        
        NSDictionary *argsDict = [NSDictionary dictionary];
        ITDb *db = [ITDb new];
        
        for(NSDictionary *item in response) {
            
            NSDictionary *movie = [item objectForKey:@"movie"];
            NSDictionary *ids = [movie objectForKey:@"ids"];
            
            argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [ITUtil md5HexDigest:[NSString stringWithFormat:@"%@%@", [ids objectForKey:@"trakt"], [item objectForKey:@"last_watched_at"]]], @"uid",
                        [ids objectForKey:@"tmdb"], @"tmdb_id",
                        [ids objectForKey:@"imdb"], @"imdb_id",
                        @"movie", @"type",
                        @"history sync", @"action",
                        [item objectForKey:@"last_watched_at"], @"timestamp",
                        nil];
            
            NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
            [db executeUpdateUsingQueue:qry arguments:argsDict];
            
            NSDictionary *result = [db executeAndGetOneResult:@"SELECT movieId FROM movies WHERE tmdb_id = :id OR imdb_id = :imdb OR trakt_id = :trakt" arguments:
                                    [NSArray arrayWithObjects:
                                     [ids objectForKey:@"tmdb"],
                                     [ids objectForKey:@"imdb"],
                                     [ids objectForKey:@"trakt"],
                                     nil
                                     ]];
            
            if(result == nil) {
                
                argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [ids objectForKey:@"trakt"], @"trakt_id",
                            [ids objectForKey:@"tmdb"], @"tmdb_id",
                            [ids objectForKey:@"imdb"], @"imdb_id",
                            [movie objectForKey:@"year"], @"year",
                            [item objectForKey:@"plays"], @"traktPlays",
                            [movie objectForKey:@"title"], @"title",
                            [ids objectForKey:@"slug"],   @"traktUrl",
                            nil];
                
                [db executeUpdateUsingQueue:[db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"movies"] arguments:argsDict];
            }
        }
    }];
}

@end
