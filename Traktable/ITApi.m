//
//  trakt.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITApi.h"
#import "ITTVShow.h"
#import "ITMovie.h"
#import "ITConfig.h"
#import "ITDb.h"
#import "ITUtil.h"
#import "ITTrakt.h"
#import "ITTraktConstants.h"
#import "ITNotification.h"
#import "Unirest.h"
#import "ITConstants.h"
#import "WebViewController.h"
#import "NSData+Additions.h"
#import <OAuth2Client/NXOAuth2.h>

#define kApiUrl @"https://api-v2launch.trakt.tv"

@interface ITApi()

@property(strong) WebViewController *oAuthWindow;
@property(strong) ITConfig *config;

@end


@implementation ITApi

- (id)init {
    
    self.config = [ITConfig sharedObject];
    
    return self;
}

- (void)updateState:(id)aVideo state:(ITVideoPlayerState *)aState {
    
    NSDictionary *traktObject;
    NSString *type;
    
    if([aVideo isKindOfClass:[ITTVShow class]]) {
        
        traktObject = [ITTVShow traktEntity:aVideo batch:nil];
        type = @"show";
        
    } else if ([aVideo isKindOfClass:[ITMovie class]]) {
        
        traktObject = [ITMovie traktEntity:aVideo batch:nil];
        type = @"movie";
        
    }
    
    NSString *playerStateString = [ITVideo playerStateString:aState];
    NSDictionary *notification = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:playerStateString, aVideo, nil] forKeys:[NSArray arrayWithObjects:@"state", @"video", nil]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", kITTraktScrobbleUrl, playerStateString];
    
    if([playerStateString isEqualToString:@"stop"])
        [self newTraktQueueEntry:traktObject url:url];
    
    ITTrakt *traktClient = [ITTrakt sharedClient];
    [traktClient POST:url withParameters:traktObject completionHandler:^(id response, NSError *err) {

        if(![response isKindOfClass:[NSDictionary class]]) {
            
            NSLog(@"Response is not an NSDictionary: %@", err);
            return;
        }
        
        NSLog(@"Succes: Request params %@ reponse = %@", traktObject, response);
        
        [self removeTraktQueueEntry:traktObject url:url];
        
        if([[notification objectForKey:@"state"] isEqual: @"stop"])
            [ITNotification showNotification:[NSString stringWithFormat:@"Scrobbled: %@", [notification objectForKey:@"video"]]];
        
        if (err) NSLog(@"Error: %@",[err description]);
    }];
}

- (void)batch:(NSDictionary *)videos {
    
    ITTrakt *traktClient = [ITTrakt sharedClient];
    [traktClient POST:kITTraktSyncHistoryUrl withParameters:videos completionHandler:^(id response, NSError *err) {
        
        if(![response isKindOfClass:[NSDictionary class]]) {
            
            NSLog(@"Response is not an NSDictionary: %@", err);
            return;
        }
        
        if (err) NSLog(@"Error: %@",[err description]);
    }];
}

- (void)library:(NSArray *)videos type:(iTunesEVdK)videoType video:(id)aVideo {
    
    NSDictionary *params;
    NSString *type;
    
    if(videoType == iTunesEVdKTVShow) {
        
        //params = [self TVShow:aVideo batch:videos];
        type = @"show/episode";
        
    } else if(videoType == iTunesEVdKMovie) {
        
        //params = [self Movie:nil batch:videos];
        type = @"movie";
    }

    //NSString *url = [NSString stringWithFormat:@"%@/%@/library/%@", kApiUrl, type, [self apiKey]];
    
    //[self callAPI:url WithParameters:params notification:nil];
}

- (NSDictionary *)getSummary:(NSString *)videoType videoId:(NSNumber *)videoId {
    
    return [self getSummary:videoType videoId:videoId season:nil episode:nil];
}

- (NSDictionary *)getSummary:(NSString *)videoType videoId:(NSNumber *)videoId season:(NSNumber *)seasonNumber episode:(NSNumber *)episodeNumber {
    
    NSString *url;
    /*
    if(!seasonNumber)
        //url = [NSString stringWithFormat:@"%@/%@/summary.json/%@/%@", kApiUrl, videoType, [self apiKey], videoId];
    else
       //url = [NSString stringWithFormat:@"%@/%@/summary.json/%@/%@/%@/%@", kApiUrl, videoType, [self apiKey], videoId, seasonNumber, episodeNumber];
    */
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"accept", nil];
    
    HttpJsonResponse* response = [[Unirest get:^(SimpleRequest* request) {
        [request setUrl:url];
        [request setHeaders:headers];
    }] asJson];
    
    JsonNode* body = [response body];
    
    id responseObject = [body JSONObject];
    
    if([responseObject isKindOfClass:[NSDictionary class]])
        return (NSDictionary *) responseObject;
    
    return nil;
}

- (NSArray *)watchedSync:(iTunesEVdK)videoType extended:(NSString *)ext {
    
    NSLog(@"SYNC IS OFF");
    return nil;
    
    NSString *type;
        
    if(videoType == iTunesEVdKTVShow) {
        
        type = @"shows";
        
    } else if(videoType == iTunesEVdKMovie) {
        
        type = @"movies";
    }
    
    NSString *url;// = [NSString stringWithFormat:@"%@/user/library/%@/watched.json/%@/%@/%@", kApiUrl, type, [self apiKey], self.username, ext];
    
    NSDictionary* headers;
    
    HttpJsonResponse* response = [[Unirest get:^(SimpleRequest* request) {
        [request setUrl:url];
        [request setHeaders:headers];
    }] asJson];
    
    JsonNode* body = [response body];
    
    id responseObject = [body JSONArray];

    if([responseObject isKindOfClass:[NSArray class]])
        return (NSArray *) responseObject;
    
    return nil;
}

- (void)historySync {
    
    NSLog(@"SYNC IS OFF");
    return;
    
    NSInteger lastSync = [[NSUserDefaults standardUserDefaults] integerForKey:@"traktable.ITHistorySyncLast"];
    
    if(lastSync < 1262325600)
        lastSync = 1262325600;
    
    NSString *url;// = [NSString stringWithFormat:@"%@/activity/user.json/%@/%@/movie,show,episode/scrobble,seen,checkin/%ld?min=1", kApiUrl, [self apiKey], self.username, (long)lastSync];

    NSDictionary* headers;
    
    HttpJsonResponse* response = [[Unirest get:^(SimpleRequest* request) {
        [request setUrl:url];
        [request setHeaders:headers];
    }] asJson];
    
    JsonNode* body = [response body];
    
    id responseObject = [body JSONObject];
    
    if([responseObject isKindOfClass:[NSDictionary class]]) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSDate date] timeIntervalSince1970] forKey:@"traktable.ITHistorySyncLast"];
        
        int n = 0;
        
        for(NSDictionary *activity in [responseObject objectForKey:@"activity"]) {
            
            n++;
            
            int progress = (100 / [[responseObject objectForKey:@"activity"] count]) * n;
            
            dispatch_async(dispatch_get_main_queue(),^{
                // Update progress
                [[NSNotificationCenter defaultCenter] postNotificationName:kITUpdateProgressWindowNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:progress],@"progress",@"history",@"type", nil]];
            });
            
            [self updateHistory:activity parameters:nil];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITHistoryNeedsUpdateNotification object:nil];
}

- (void)updateHistory:(NSDictionary *)update parameters:(NSDictionary *)params {
    
    NSLog(@"SYNC IS OFF");
    return;
    
    ITDb *db = [ITDb new];

    NSDictionary *argsDict = [NSDictionary dictionary];
    
    if([update objectForKey:@"type"] != nil && [[update objectForKey:@"type"] isEqualToString:@"episode"]) {

        NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[update objectForKey:@"timestamp"] doubleValue]];
        
        if([update objectForKey:@"episode"] != nil) {
    NSString *uid = @"regelen";
             argsDict = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"uid",[[update objectForKey:@"show"] objectForKey:@"tvdb_id"], @"tvdb_id", [[update objectForKey:@"show"] objectForKey:@"imdb_id" ], @"imdb_id", @"show", @"type",[update objectForKey:@"action"], @"action", [[update objectForKey:@"episode"] objectForKey:@"season"], @"season", [[update objectForKey:@"episode"] objectForKey:@"number"], @"episode", [timestamp descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
            
            NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
            
            [db executeUpdateUsingQueue:qry arguments:argsDict];
            
            //NSLog(@"%@",[db lastErrorMessage]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kITTVShowNeedsUpdateNotification object:nil userInfo:argsDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:kITTVShowEpisodeNeedsUpdateNotification object:nil userInfo:argsDict];
        
        } else if([update objectForKey:@"episodes"] != nil) {
            
            for(NSDictionary *episode in [update objectForKey:@"episodes"]) {
             NSString *uid = @"regelen";      
                argsDict = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"uid",[[update objectForKey:@"show"] objectForKey:@"tvdb_id"], @"tvdb_id", [[update objectForKey:@"show"] objectForKey:@"imdb_id" ], @"imdb_id", @"show", @"type",[update objectForKey:@"action"], @"action", [episode objectForKey:@"season"], @"season", [episode objectForKey:@"number"], @"episode", [timestamp descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
                
                NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
                
                [db executeUpdateUsingQueue:qry arguments:argsDict];
                
                //NSLog(@"%@",[db lastErrorMessage]);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kITTVShowEpisodeNeedsUpdateNotification object:nil userInfo:argsDict];
            }
        }    
        
    } else if([update objectForKey:@"movie"] != nil) {
        
        NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[update objectForKey:@"timestamp"] doubleValue]];
    NSString *uid = @"regelen";
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"uid",[[update objectForKey:@"movie"] objectForKey:@"tmdb_id" ], @"tmdb_id", [[update objectForKey:@"movie"] objectForKey:@"imdb_id" ], @"imdb_id", @"movie", @"type", [update objectForKey:@"action"], @"action", [timestamp descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
        
        NSDictionary *dict = [argsDict copy];
        NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
        
        [db executeUpdateUsingQueue:qry arguments:argsDict];
        
        //NSLog(@"%@",[db lastErrorMessage]);

        [[NSNotificationCenter defaultCenter] postNotificationName:kITMovieNeedsUpdateNotification object:nil userInfo:dict];
    } 
}

- (void)traktError:(NSDictionary *)response {
    
    ITDb *db = [ITDb new];
    
    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[response objectForKey:@"error"], @"description", [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
    
    NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"INSERT" forTable:@"errors"];
    
    [db executeUpdateUsingQueue:qry arguments:argsDict];
    
    //NSLog(@"%@",[db lastErrorMessage]);
}

- (void)newTraktQueueEntry:(NSDictionary *)params url:(NSString *)url {
    
    ITDb *db = [ITDb new];
    
    NSString *paramsString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding];

    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:url, @"url", paramsString, @"params", nil];
    
    NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"INSERT" forTable:@"traktQueue"];
    
    [db executeUpdateUsingQueue:qry arguments:argsDict];
    
}

- (void)removeTraktQueueEntry:(NSDictionary *)params url:(NSString *)url {
 
    ITDb *db = [ITDb new];
    
    NSString *paramsString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding];
 
    [db executeAndGetResults:@"delete from traktQueue where url=? AND params = ? " arguments:[NSArray arrayWithObjects:url,paramsString, nil]];
    
    NSLog(@"%@",[db lastErrorMessage]);
}

- (void)retryTraktQueue {
    
    ITDb *db = [ITDb new];
    
    NSArray *results = [db executeAndGetResults:@"select * from traktQueue" arguments:nil];
    
    for(NSDictionary *result in results) {
       
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[[result objectForKey:@"params"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        ITTrakt *traktClient = [ITTrakt sharedClient];
        [traktClient POST:[result objectForKey:@"url"] withParameters:params completionHandler:^(id response, NSError *err) {
            
            if(![response isKindOfClass:[NSDictionary class]]) {
                
                NSLog(@"Response is not an NSDictionary: %@", err);
                return;
            }
            
            if (err) NSLog(@"Error: %@",[err description]);
        }];
    }
}


@end
