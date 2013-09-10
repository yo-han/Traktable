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
#import "ITEpisodeScreen.h"
#import "ITDb.h"
#import "ITUtil.h"
#import "ITConstants.h"

@implementation ITHistoryGroupHeader

- (id)initWithDateString:(NSString *)date {
    
    self = [super init];
    if (self) {
        _date = date;
    }
    return self;
}
@end

@interface ITHistory()

@property (nonatomic, strong) ITDb *db;

@end

@implementation ITHistory

@synthesize title, timestamp, poster, action, episodeTitle, episode, season;

+ (ITHistory *)historyEntityWithHistoryObject:(id)object {

    ITHistory *history = [ITHistory new];
    
    if([object isKindOfClass:[ITHistoryGroupHeader class]]) {
        
        return object;
    }
    
    if([object isKindOfClass:[ITMovie class]]) {

        ITMoviePoster *poster = [ITMoviePoster new];
        ITMovie *movie = (ITMovie *) object;

        history.title = movie.name;
        history.poster = [poster getPoster:movie.movieId withSize:ITMoviePosterSizeMedium];
        history.timestamp = movie.timestamp;
        history.year = [NSString stringWithFormat:@"%ld", movie.year];
        history.action = movie.action;
        history.traktUrl = movie.url;

        if(history.poster == nil) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                [poster poster:movie.movieId withUrl:movie.image size:ITMoviePosterSizeMedium];                
            });
        }
        
    } else if([object isKindOfClass:[ITTVShow class]]) {
        
        ITEpisodeScreen *screen = [ITEpisodeScreen new];
        ITTVShow *show = (ITTVShow *) object;
   
        history.title = show.title;
        history.poster = [screen getScreen:show.showId season:[NSNumber numberWithInt:show.seasonNumber] episode:[NSNumber numberWithInt:show.episodeNumber] withSize:ITEpisodeScreenSizeMedium];
        history.timestamp = show.timestamp;
        history.episodeTitle = show.episodeName;
        history.episode = show.episodeNumber;
        history.season = show.seasonNumber;
        history.action = show.action;
        history.traktUrl = show.url;
        
        if(history.poster == nil) {

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

                [screen screen:show.showId season:[NSNumber numberWithUnsignedLong:show.seasonNumber] episode:[NSNumber numberWithUnsignedLong:show.episodeNumber] withUrl:show.screen size:ITEpisodeScreenSizeMedium];
            });
        }
    }
    
    return history;
}

- (ITHistory *)init {
    
    _db = [ITDb new];
    
    return self;
}

- (NSArray *)fetchMovieHistory {

    NSMutableArray *movies = [NSMutableArray array];
    
    NSArray *results = [self.db executeAndGetResults:@"select * from (select m.*, h.type, h.timestamp, h.action from history h left join movies m on h.imdb_id = m.imdb_id WHERE movieId IS NOT NULL AND h.type = 'movie' UNION select m.*, h.type, h.timestamp, h.action from history h left join movies m on h.tmdb_id = m.tmdb_id WHERE movieId IS NOT NULL AND h.type = 'movie') ORDER BY timestamp DESC" arguments:nil];
    
    NSString *lastGroup = nil;
    
    for (NSDictionary *result in results) {
        
        NSString *date = [ITUtil localeDateString:[result objectForKey:@"timestamp"]];
        
        if(![lastGroup isEqualToString:date]) {
            ITHistoryGroupHeader *header = [[ITHistoryGroupHeader alloc] initWithDateString:date];
            [movies addObject:header];
        }
        
        ITMovie *movie = [ITMovie movieWithDatabaseRecord:result];
        [movies addObject:movie];
        
        lastGroup = date;
    }
    
    return movies;
}

- (NSArray *)fetchTvShowHistory {
    
    NSMutableArray *shows = [NSMutableArray array];
    
    NSArray *results = [self.db executeAndGetResults:@"select (SELECT screenImage FROM episodes WHERE showTvdb_id = shows.tvdb_id AND episode = shows.episode AND season = shows.season) screen, (SELECT title FROM episodes WHERE showTvdb_id = shows.tvdb_id AND episode = shows.episode AND season = shows.season) episodeTitle, * from (select t.*, h.type, h.timestamp, h.action,h.episode,h.season from history h left join tvshows t on h.imdb_id = t.imdb_id WHERE showId IS NOT NULL AND h.type = 'show' UNION select t.*, h.type, h.timestamp, h.action,h.episode,h.season from history h left join tvshows t on h.tvdb_id = t.tvdb_id WHERE showId IS NOT NULL AND h.type = 'show') as shows  ORDER BY timestamp DESC" arguments:nil];
    
    NSString *lastGroup = nil;
    
    for (NSDictionary *result in results) {
        
        NSString *date = [ITUtil localeDateString:[result objectForKey:@"timestamp"]];
        
        if(![lastGroup isEqualToString:date]) {
            ITHistoryGroupHeader *header = [[ITHistoryGroupHeader alloc] initWithDateString:date];
            [shows addObject:header];
        }
        
        ITTVShow *show = [ITTVShow showWithDatabaseRecord:result];
        [shows addObject:show];
        
        lastGroup = date;
    }
    
    return shows;
}

@end
