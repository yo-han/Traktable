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

- (void)syncTraktHistoryExtendedInBackgroundThread {
    
    //dispatch_async(self.queue, ^{ [self syncMovieHistory]; });
    dispatch_async(self.queue, ^{ [self syncTVShowsExtend]; });
}

- (void)syncTVShowsExtend {
    
    ITDb *db = [ITDb new];
    
    __block NSMutableDictionary *argsDict;
    __block NSString *qry;
    
    NSArray *shows = [db executeAndGetResults:@"SELECT showId, traktUrl FROM tvshows WHERE extended = 0" arguments:nil];
    
    for(NSDictionary *show in shows) {
        
        ITTrakt *traktClient = [ITTrakt sharedClient];
        [traktClient GET:[NSString stringWithFormat:kITTraktSyncWatchedShowsExtendedUrl, [show objectForKey:@"traktUrl"]]  withParameters:nil completionHandler:^(id response, NSError *err) {

            argsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        @"1", @"extended",
                        [response objectForKey:@"first_aired"], @"runtime",
                        [response objectForKey:@"aired_episodes"], @"episodes",
                        [response objectForKey:@"first_aired"], @"firstAired",
                        [response objectForKey:@"status"], @"status",
                        [response objectForKey:@"overview"], @"overview",
                        [response objectForKey:@"network"], @"network",
                        [[response objectForKey:@"genres"]  componentsJoinedByString:@","], @"genres",
                        [response objectForKey:@"country"], @"country",
                        [response objectForKey:@"rating"], @"rating",
                        [[response objectForKey:@"airs"] objectForKey:@"time"], @"airTime",
                        [[response objectForKey:@"airs"] objectForKey:@"day"], @"airDay",
                        nil];
            
            qry = [db getUpdateQueryFromDictionary:argsDict
               forTable:@"tvshows"
               whereCol:@"trakt_id"
             ];
            
            [argsDict setObject:[[response objectForKey:@"ids"] objectForKey:@"trakt"] forKey: @"where"];
            
            [db executeUpdateUsingQueue:qry arguments:argsDict];
        }];      
    }
    
    NSArray *episodes = [db executeAndGetResults:@"SELECT e.episodeId, e.season, e.episode, t.traktUrl FROM episodes e LEFT JOIN tvshows t ON t.tvdb_id = e.showTvdb_id WHERE e.title IS NULL" arguments:nil];
    
    for(NSDictionary *episode in episodes) {
        
        ITTrakt *traktClient = [ITTrakt sharedClient];
        [traktClient GET:[NSString stringWithFormat:kITTraktSyncWatchedShowsEpisodeExtendedUrl, [episode objectForKey:@"traktUrl"], [episode objectForKey:@"season"], [episode objectForKey:@"episode"]]  withParameters:nil completionHandler:^(id response, NSError *err) {
            
            argsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [[response objectForKey:@"ids"] objectForKey:@"tvdb"], @"tvdb_id",
                        [response objectForKey:@"overview"], @"overview",
                        [response objectForKey:@"title"], @"title",
                        [episode objectForKey:@"traktUrl"], @"traktUrl",
                        nil];
            
            qry = [db getUpdateQueryFromDictionary:argsDict
                                          forTable:@"episodes"
                                          whereCol:@"episodeId"
                   ];
            
            [argsDict setObject:[episode objectForKey:@"episodeId"] forKey: @"where"];
            
            [db executeUpdateUsingQueue:qry arguments:argsDict];
        }];
    }
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

                    NSDictionary *result = [db executeAndGetOneResult:@"SELECT episodeId FROM episodes WHERE trakt_id = :trakt AND season = :season AND episode = :ep" arguments:
                                            [NSArray arrayWithObjects:
                                             [ids objectForKey:@"trakt"],
                                             [season objectForKey:@"number"],
                                             [episode objectForKey:@"number"],
                                             nil
                                             ]];

                    if(result == nil) {
                        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [ids objectForKey:@"tvdb"], @"showTvdb_id",
                                    [ids objectForKey:@"imdb"], @"showImdb_id",
                                    [ids objectForKey:@"trakt"], @"trakt_id",
                                    [NSNull null], @"tvdb_Id",
                                    [episode objectForKey:@"number"], @"episode",
                                    [season objectForKey:@"number"], @"season",
                                    nil];
                        
                        qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"episodes"];
                        [db executeUpdateUsingQueue:qry arguments:argsDict];
                    }
                }
            }
            
            NSDictionary *result = [db executeAndGetOneResult:@"SELECT showId FROM tvshows WHERE tmdb_id = :id OR imdb_id = :imdb OR trakt_id = :trakt" arguments:
                                    [NSArray arrayWithObjects:
                                     [ids objectForKey:@"tmdb"],
                                     [ids objectForKey:@"imdb"],
                                     [ids objectForKey:@"trakt"],
                                     nil
                                     ]];
            
            if(result == nil) {
                argsDict = [NSDictionary dictionaryWithObjectsAndKeys:
                            [ids objectForKey:@"tvdb"], @"tvdb_id",
                            [ids objectForKey:@"imdb"], @"imdb_id",
                            [ids objectForKey:@"tvrage"], @"tvrage_id",
                            [ids objectForKey:@"trakt"], @"trakt_id",
                            [ids objectForKey:@"slug"],   @"traktUrl",
                            @"0", @"extended",
                            [show objectForKey:@"year"], @"year",
                            [show objectForKey:@"title"], @"title",
                            nil];
                
                qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"tvshows"];
                [db executeUpdateUsingQueue:qry arguments:argsDict];
            }
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
