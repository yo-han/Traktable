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

@end
