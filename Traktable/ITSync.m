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
        
        // Register an observer for history updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMovieData:) name:kITMovieNeedsUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTVShowData:) name:kITTVShowNeedsUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEpisodeData:) name:kITTVShowEpisodeNeedsUpdateNotification object:nil];        
    }
    
    return self;
}

- (void)syncTraktExtended {
    
    _extended = YES;
    
    /** Sync movies **/
    [self sync:iTunesEVdKMovie extended:self.extended];

    /** Sync series **/
    [self sync:iTunesEVdKTVShow extended:self.extended];

    /** Sync trakt history **/
    ITApi *api = [ITApi new];
    [api historySync];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITHideProgressWindowNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kITHistoryTableReloadNotification object:nil];
}

- (void)sync:(iTunesEVdK)type extended:(BOOL)extended {
    
    ITApi *api = [ITApi new];
    ITDb *db = [ITDb new];
    
    NSArray *items = [api watchedSync:type extended:[NSString stringWithFormat:@"%d",extended]];
    int n = 0;
    
    for(NSDictionary *item in items) {
        
        NSDictionary *argsDict;
        NSString *table;
        
        if(type == iTunesEVdKMovie) {
            
            argsDict = [self getMovieParameters:item extended:extended];
            table = @"movies";
            
            if([db executeAndGetOneResult:@"SELECT overview FROM movies WHERE tmdb_id = :id" arguments:[NSArray arrayWithObject:[item objectForKey:@"tmdb_id"]]] != nil)
                continue;
            
        } else if(type == iTunesEVdKTVShow) {
            
            argsDict = [self getTVShowParameters:item extended:extended];
            table = @"tvshows";
            
            if([db executeAndGetOneResult:@"SELECT overview FROM tvshows WHERE tvdb_id = :id" arguments:[NSArray arrayWithObject:[item objectForKey:@"tvdb_id"]]] != nil)
                continue;
        }
        
        [db executeUpdateUsingQueue:[db getInsertQueryFromDictionary:argsDict queryType:@"INSERT" forTable:table] arguments:argsDict];
        
        //NSLog(@"%@",[db lastErrorMessage]);
        
        NSNumber *lastId = [db lastInsertRowId];
        
        n++;
        
        int progress = (100 / [items count]) * n;
        
        // Update progress
        [[NSNotificationCenter defaultCenter] postNotificationName:kITUpdateProgressWindowNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:progress],@"progress",table,@"type", nil]];
        
        if([lastId intValue] == 0)
            continue;
        
        dispatch_async(self.queue,
           ^{
               if(type == iTunesEVdKMovie) {
                   [self getMoviePoster:lastId poster:[argsDict objectForKey:@"poster"]];
               } else if(type == iTunesEVdKTVShow) {
                   [self getTVShowPoster:lastId poster:[argsDict objectForKey:@"poster"]];
               }
           });
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITHistoryNeedsUpdateNotification object:nil];
}

- (void) updateMovieData:(NSNotification *)notification {
 
    ITDb *db = [ITDb new];
    ITApi *api = [ITApi new];
    
    NSDictionary *item = notification.userInfo;
    NSNumber *videoId = [item objectForKey:@"tmdb_id"];
    NSString *imdbId = [item objectForKey:@"imdb_id"];
    
    NSDictionary *result = [db executeAndGetOneResult:@"SELECT extended, movieId FROM movies WHERE tmdb_id = :id OR imdb_id = :imdb" arguments:[NSArray arrayWithObjects:videoId,imdbId, nil]];

    if(result == nil || [[result objectForKey:@"extended"] isKindOfClass:[NSNull class]] || [[result objectForKey:@"extended"] intValue] == 0) {

        NSDictionary *movie = [api getSummary:@"movie" videoId:videoId];
        NSDictionary *argsDict = [self getMovieParameters:movie extended:YES];
        NSMutableDictionary *argsDictWhere = [NSMutableDictionary dictionaryWithDictionary:argsDict];
        
        if(result == nil)
            [db executeUpdateUsingQueue:[db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"movies"] arguments:argsDict];
        else {
            [argsDictWhere setObject:[result objectForKey:@"movieId"] forKey:@"where"];
            [db executeUpdateUsingQueue:[db getUpdateQueryFromDictionary:argsDict forTable:@"movies" whereCol:@"movieId"] arguments:argsDictWhere];
        }
        //NSLog(@"%@",[db lastErrorMessage]);
    }
}

- (void) updateTVShowData:(NSNotification *)notification {
    
    ITDb *db = [ITDb new];
    ITApi *api = [ITApi new];
    
    NSDictionary *item = notification.userInfo;
    NSNumber *videoId = [item objectForKey:@"tvdb_id"];
    NSString *imdbId = [item objectForKey:@"imdb_id"];

    NSDictionary *result = [db executeAndGetOneResult:@"SELECT extended,showId FROM tvshows WHERE (tvdb_id = :id OR imdb_id = :imdb)" arguments:[NSArray arrayWithObjects:videoId,imdbId, nil]];
    
    if(result == nil || [[result objectForKey:@"extended"] isKindOfClass:[NSNull class]] || [[result objectForKey:@"extended"] intValue] == 0) {
        
        NSDictionary *show = [api getSummary:@"show" videoId:videoId];
        NSDictionary *argsDict = [self getTVShowParameters:show extended:YES];
        NSMutableDictionary *argsDictWhere = [NSMutableDictionary dictionaryWithDictionary:argsDict];
        
        if(result == nil)
            [db executeUpdateUsingQueue:[db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"tvshows"] arguments:argsDict];
        else {
            [argsDictWhere setObject:[result objectForKey:@"showId"] forKey:@"where"];
            [db executeUpdateUsingQueue:[db getUpdateQueryFromDictionary:argsDict forTable:@"tvshows" whereCol:@"showId"] arguments:argsDictWhere];
        }
        
        //NSLog(@"%@",[db lastErrorMessage]);
    }
}

- (void) updateEpisodeData:(NSNotification *)notification {
    
    ITDb *db = [ITDb new];
    ITApi *api = [ITApi new];
    
    NSDictionary *item = notification.userInfo;
    
    if(item == nil)
        return;
    
    NSNumber *videoId = [item objectForKey:@"tvdb_id"];
    NSNumber *episode = [item objectForKey:@"episode"];
    NSNumber *season = [item objectForKey:@"season"];

    NSDictionary *result = [db executeAndGetOneResult:@"SELECT episodeId FROM episodes WHERE showTvdb_id = :id AND season = :season AND episode = :episode" arguments:[NSArray arrayWithObjects:videoId, season, episode, nil]];

    if(result == nil) {
        
        NSDictionary *show = [api getSummary:@"show/episode" videoId:videoId season:season episode:episode];
        NSDictionary *argsDict = [self getEpisodeParameters:show];
        NSMutableDictionary *argsDictWhere = [NSMutableDictionary dictionaryWithDictionary:argsDict];
        
        if(result == nil)
            [db executeUpdateUsingQueue:[db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"episodes"] arguments:argsDict];
        else {
            [argsDictWhere setObject:[result objectForKey:@"episodeId"] forKey:@"where"];
            [db executeUpdateUsingQueue:[db getUpdateQueryFromDictionary:argsDict forTable:@"episodes" whereCol:@"episodeId"] arguments:argsDictWhere];
        }
        
        //NSLog(@"%@",[db lastErrorMessage]);
    }
}

- (NSDictionary *)getMovieParameters:(NSDictionary *)movie extended:(BOOL)extended {
    
    NSString *posterUrl = [[movie objectForKey:@"images"] objectForKey:@"poster"];
    NSString *genres = [[movie objectForKey:@"genres"] componentsJoinedByString:@","];
    NSString *plays = [movie objectForKey:@"plays"];
    NSDictionary *argsDict;
    
    if(plays == nil)
        plays = @"0";
    
    if(extended) {
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[movie objectForKey:@"tmdb_id"], @"tmdb_id", [movie objectForKey:@"imdb_id"],@"imdb_id",@"1",@"extended",[movie objectForKey:@"year"],@"year", posterUrl,@"poster",plays,@"traktPlays",[movie objectForKey:@"released"],@"released",[movie objectForKey:@"runtime"],@"runtime",[movie objectForKey:@"title"],@"title",[movie objectForKey:@"overview"],@"overview",[movie objectForKey:@"tagline"],@"tagline",[movie objectForKey:@"url"],@"traktUrl",[movie objectForKey:@"trailer"],@"trailer",genres,@"genres", nil];
        
    } else {
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[movie objectForKey:@"tmdb_id"], @"tmdb_id", [movie objectForKey:@"imdb_id"],@"imdb_id",[movie objectForKey:@"year"],@"year", posterUrl,@"poster",plays,@"traktPlays",[movie objectForKey:@"title"],@"title",genres,@"genres",[movie objectForKey:@"url"],@"traktUrl", nil];
    }
    
    return argsDict;
}

- (NSDictionary *)getTVShowParameters:(NSDictionary *)serie extended:(BOOL)extended {
    
    NSString *posterUrl = [[serie objectForKey:@"images"] objectForKey:@"poster"];
    NSString *seasons = [[[serie objectForKey:@"seasons"] objectAtIndex:0] objectForKey:@"season"];
    NSString *episodes = [[[[serie objectForKey:@"seasons"] objectAtIndex:0] objectForKey:@"episodes"] componentsJoinedByString:@","];
    NSString *genres = [[serie objectForKey:@"genres"] componentsJoinedByString:@","];
    NSDictionary *argsDict;

    if(extended) {
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[serie objectForKey:@"tvdb_id"], @"tvdb_id", [serie objectForKey:@"tvrage_id"],@"tvrage_id", [serie objectForKey:@"imdb_id"],@"imdb_id",@"1",@"extended",[serie objectForKey:@"year"],@"year", posterUrl,@"poster",seasons,@"seasons",episodes,@"episodes",[serie objectForKey:@"first_aired"],@"firstAired",[serie objectForKey:@"runtime"],@"runtime",[serie objectForKey:@"title"],@"title",[serie objectForKey:@"overview"],@"overview",[serie objectForKey:@"status"],@"status",[serie objectForKey:@"url"],@"traktUrl",[serie objectForKey:@"network"],@"network",[serie objectForKey:@"country"],@"country",[serie objectForKey:@"certification"],@"rating",[serie objectForKey:@"air_time"],@"airTime",[serie objectForKey:@"air_day"],@"airDay",genres,@"genres", nil];
        
    } else {
        
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[serie objectForKey:@"tvdb_id"], @"tvdb_id", [serie objectForKey:@"tvrage_id"],@"tvrage_id", [serie objectForKey:@"imdb_id"],@"imdb_id",[serie objectForKey:@"year"],@"year", posterUrl,@"poster",seasons,@"seasons",episodes,@"episodes",[serie objectForKey:@"title"],@"title",[serie objectForKey:@"overview"],@"overview",[serie objectForKey:@"status"],@"status",[serie objectForKey:@"url"],@"traktUrl",genres,@"genres", nil];
    }

    return argsDict;
}

- (NSDictionary *)getEpisodeParameters:(NSDictionary *)showEpisode {
    
    NSDictionary *argsDict;
    NSDictionary *episode = [showEpisode objectForKey:@"episode"];
    NSDictionary *show = [showEpisode objectForKey:@"show"];
    
    NSString *screen = [[episode objectForKey:@"images"] objectForKey:@"screen"];    
    
    argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[show objectForKey:@"tvdb_id"], @"showTvdb_id",[episode objectForKey:@"tvdb_id"], @"tvdb_id",[show objectForKey:@"imdb_id"], @"showImdb_id",[episode objectForKey:@"season"], @"season",[episode objectForKey:@"number"], @"episode",screen, @"screenImage",[episode objectForKey:@"overview"], @"overview",[episode objectForKey:@"title"], @"title",[episode objectForKey:@"url"], @"traktUrl", nil];
    
    return argsDict;
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


@end
