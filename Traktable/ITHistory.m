//
//  ITHistory.m
//  Traktable
//
//  Created by Johan Kuijt on 05-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITHistory.h"
#import "ITMovie.h"
#import "ITMoviePoster.h"
#import "ITTVShow.h"
#import "ITTVShowPoster.h"
#import "ITDb.h"

@interface ITHistory()

@property (nonatomic, strong) ITDb *db;

@end

@implementation ITHistory

@synthesize title, timestamp, success, poster;

+ (ITHistory *)historyEntityWithHistoryObject:(id)object {

    ITHistory *history = [ITHistory new];
    
    if([object isKindOfClass:[ITMovie class]]) {

        ITMoviePoster *poster = [ITMoviePoster new];
        ITMovie *movie = (ITMovie *) object;

        history.title = movie.name;
        history.poster = [poster getPoster:movie.movieId withSize:ITMoviePosterSizeSmall];
        history.success = movie.success;
        history.timestamp = movie.timestamp;
        
    } else if([object isKindOfClass:[ITTVShow class]]) {
        
        ITTVShowPoster *poster = [ITTVShowPoster new];
        ITTVShow *show = (ITTVShow *) object;
        
        history.title = show.title;
        history.poster = [poster getPoster:show.showId withSize:ITTVShowPosterSizeSmall];
        history.success = show.success;
        history.timestamp = show.timestamp;
    }
    
    return history;
}

- (ITHistory *)init {
    
    _db = [ITDb new];
    
    return self;
}

- (NSArray *)fetchMovieHistory {

    NSMutableArray *movies = [NSMutableArray array];
    
    NSArray *results = [self.db executeAndGetResults:@"select * from (select m.*, h.type, h.success, h.comment, h.timestamp from history h left join movies m on h.imdb_id = m.imdb_id WHERE movieId IS NOT NULL UNION select m.*, h.type, h.success, h.comment, h.timestamp from history h left join movies m on h.tmdb_id = m.tmdb_id WHERE movieId IS NOT NULL) ORDER BY timestamp DESC" arguments:nil];
    
    //NSLog(@"%@",[self.db lastErrorMessage]);
    
    for (NSDictionary *result in results) {
        
        ITMovie *movie = [ITMovie movieWithDatabaseRecord:result];
        [movies addObject:movie];
    }
    
    return movies;
}

- (NSArray *)fetchTvShowHistory {
    
    NSMutableArray *shows = [NSMutableArray array];
    
    NSArray *results = [self.db executeAndGetResults:@"select * from (select t.*, h.type, h.success, h.comment, h.timestamp from history h left join tvshows t on h.imdb_id = t.imdb_id WHERE showId IS NOT NULL UNION select t.*, h.type, h.success, h.comment, h.timestamp from history h left join tvshows t on h.tvdb_id = t.tvdb_id WHERE showId IS NOT NULL) ORDER BY timestamp DESC" arguments:nil];
    
    //NSLog(@"%@",[self.db lastErrorMessage]);
    
    for (NSDictionary *result in results) {
        
        ITTVShow *show = [ITTVShow showWithDatabaseRecord:result];
        [shows addObject:show];
    }
    
    return shows;
}

@end
