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
#import "EMKeychainItem.h"
#import "ITNotification.h"
#import "Unirest.h"
#import "ITConstants.h"
#import "WebViewController.h"
#import "NSData+Additions.h"
#import <OAuth2Client/NXOAuth2.h>

#define kApiUrl @"https://api-v2launch.trakt.tv"

@interface ITApi()

- (NSString *)sha1Hash:(NSString *)input;
- (NSString *)apiKey;

- (NSDictionary *)TVShow:(ITTVShow *)aTVShow batch:(NSArray *)aBatch;
- (NSDictionary *)Movie:(ITMovie *)aMovie batch:(NSArray *)aBatch;

- (void)callAPI:(NSString*)apiCall WithParameters:(NSDictionary *)params notification:(NSDictionary *)notification;
- (id)callURLSync:(NSString *)requestUrl withParameters:(NSDictionary *)params;
- (void)callURL:(NSString *)requestUrl withParameters:(NSDictionary *)params completionHandler:(void (^)(id, NSError *))completionBlock;

@property(strong) WebViewController *oAuthWindow;

@end


@implementation ITApi

- (NSString *)sha1Hash:(NSString *)input   {
    
    const char *cstr = [input UTF8String];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA1(data.bytes, (int) data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA1 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }    
    
    return output;
}

- (NSString *)apiKey {
    
    NSDictionary *config = [ITConfig getConfigFile];
    
    return [config objectForKey:@"traktApiKey"];
}

- (NSString *)apiSecret {
    
    NSDictionary *config = [ITConfig getConfigFile];
    
    return [config objectForKey:@"traktApiSecret"];
}

- (NSString *)username {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (!username) {
        username = nil;
    }
    
    return username;
}

- (NSString *)password {
    
    EMGenericKeychainItem *keychain = [EMGenericKeychainItem genericKeychainItemForService:@"com.mustacherious.Traktable" withUsername:self.username];
    
    if (!keychain) {
        return nil;
    }

    return [self sha1Hash:keychain.password];
}

- (BOOL)collection {
    
    NSString *collection = [[NSUserDefaults standardUserDefaults] objectForKey:@"collection"];
    if (!collection) {
        collection = NO;
    }
    
    return collection;
}

- (void)setPassword:(NSString *)password {
    
    [EMGenericKeychainItem setKeychainPassword:password forUsername:self.username service:@"com.mustacherious.Traktable"];
}

- (NSDictionary *)TVShow:(ITTVShow *)aTVShow batch:(NSArray *)aBatch {
    
    NSDictionary *params;
    NSString *appVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSString *compileDate = [NSString stringWithUTF8String:__DATE__];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM d yyyy"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:usLocale];
    NSDate *aDate = [df dateFromString:compileDate];
    NSLog(@"%@", aTVShow);
    if (aTVShow && aBatch == nil) {
        
        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                  aTVShow.show, @"title",
                  [NSString stringWithFormat:@"%ld", aTVShow.seasonNumber], @"season",
                  [NSString stringWithFormat:@"%ld", aTVShow.episodeNumber], @"episode",
                  [NSString stringWithFormat:@"%ld", aTVShow.year], @"year",
                  [NSString stringWithFormat:@"%ld", aTVShow.duration], @"duration",
                  @"99", @"progress",
                  appVersion, @"app_version",
                  [aDate descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], @"app_date",
                  nil];

    } else if(aTVShow != nil && aBatch != nil) {
        
        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                  aTVShow.show, @"title",
                  [NSString stringWithFormat:@"%ld", aTVShow.year], @"year",
                  aBatch, @"episodes",
                  nil];
    } else {
        
        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                  nil];
        
    }

    
    return params;
}

- (NSDictionary *)Movie:(ITMovie *)aMovie batch:(NSArray *)aBatch {
    
    NSDictionary *params;
    NSString *appVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSLog(@"%@", aMovie);
    if (aMovie && aBatch == nil) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  aMovie.name, @"title",
                  aMovie.imdbId, @"imdb_id",
                  [NSString stringWithFormat:@"%ld", aMovie.year], @"year",
                  [NSString stringWithFormat:@"%ld", aMovie.duration], @"duration",
                  @"50", @"progress",
                  appVersion, @"plugin_version",
                  @"1.0", @"media_center_version",
                  [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"media_center_date",
                  nil];
        
    } else if(aMovie == nil && aBatch != nil){
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.username, @"username",
                  self.password, @"password",
                  aBatch, @"movies",
                  nil];
    } else {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.username, @"username",
                  self.password, @"password",
                  nil];

    }
    
    return params;
}

- (id)callURLSync:(NSString *)requestUrl withParameters:(NSDictionary *)params {
    
    NSString *code = [[NSUserDefaults standardUserDefaults] stringForKey:@"TraktOAuthCode"];
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"accept", @"trakt-api-version", @"2", @"trakt-api-key", [self apiKey], @"Authorization", code, nil];
    HttpJsonResponse* response = nil;
    
    if([ITConstants traktReachable]) {
        
        @try {
            response = [[Unirest postEntity:^(BodyRequest* request) {
                [request setUrl:requestUrl];
                [request setHeaders:headers];
                [request setBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
            }] asJson];
            
        } @catch (NSException *e ) {
            NSLog(@"callURLSync:withParameters: response error");
        }
    }
    
    id responseObject = nil;
    
    if([response rawBody] != nil) {

        responseObject = [NSJSONSerialization JSONObjectWithData:[response rawBody] options:0 error:nil];
    }
    
    return responseObject;
}

- (void)callURL:(NSString *)requestUrl withParameters:(NSDictionary *)params completionHandler:(void (^)(id , NSError *))completionBlock
{    
    NSURL *URL = [NSURL URLWithString:requestUrl];
    NSString *code = [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"TraktOAuthCode"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:code forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"trakt-api-version"];
    [request setValue:[self apiKey] forHTTPHeaderField:@"trakt-api-key"];
    
    [request setHTTPBody:[@"{\"movie\": {\"title\": \"Guardians of the Galaxy\",\"year\": 2014,\"ids\": {\"trakt\": 28,\"slug\": \"guardians-of-the-galaxy-2014\",\"imdb\": \"tt2015381\",\"tmdb\": 118340}},\"progress\": 1.25, \"app_version\": \"1.0\",\"app_date\": \"2014-09-22\" }" dataUsingEncoding:NSUTF8StringEncoding]];
                          
                          NSURLSession *session = [NSURLSession sharedSession];
                          NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                                  completionHandler:
                                                        ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            
                                                            if (error) {
                                                                NSLog(@"Error %@", error);
                                                                return;
                                                            }
                                                            
                                                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                                NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                                                NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                                            }
                                                            
                                                            NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                            NSLog(@"Response Body:\n%@\n", body);
                                                        }];
                          [task resume];
                          
                          /*
    NSString *code = [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"TraktOAuthCode"]];
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-type", @"trakt-api-version", @"2", @"trakt-api-key", [self apiKey], @"Authorization", code, nil];
    NSLog(@"%@", headers);
    [[Unirest postEntity:^(BodyRequest* request) {
        
        [request setUrl:requestUrl];
        [request setHeaders:headers];
        [request setBody:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil]];
        
    }] asJsonAsync:^(HttpJsonResponse* response) {
        
        id responseObject = nil;
        
        if([response rawBody] != nil) {
      
            NSError *error;
            responseObject = [NSJSONSerialization JSONObjectWithData:[response rawBody] options:0 error:&error];

            if(error)
                NSLog(@"API Call JSON error: %@. Raw response body looked like: %@", error, [response rawBody]);
        }
        
        completionBlock(responseObject, nil);
    }];
}

- (void)callAPI:(NSString*)apiCall WithParameters:(NSDictionary *)params notification:(NSDictionary *)notification {
    
    [self callURL:apiCall withParameters:params completionHandler:^(id response, NSError *err) {

        if(![response isKindOfClass:[NSDictionary class]]) {

            NSLog(@"Response is not an NSDictionary: %@", err);
            return;
        }
                
        if ([[response objectForKey:@"status"] isEqualToString:@"success"] && [response objectForKey:@"error"] == nil){
            
            NSLog(@"Succes: %@",[response objectForKey:@"message"]);
            
            [self removeTraktQueueEntry:params url:apiCall];
            
            if([[notification objectForKey:@"state"] isEqual: @"stop"])
                [ITNotification showNotification:[NSString stringWithFormat:@"Scrobbled: %@", [notification objectForKey:@"video"]]];
            
            [self historySync];
            
        } else {
            
            [self traktError:response];
            
            NSLog(@"%@ got error: %@", apiCall, response);
        }
        
        if (err) NSLog(@"Error: %@",[err description]);
    }];
}

- (BOOL)testAccount {
    
    NSString *code = [[NSUserDefaults standardUserDefaults] stringForKey:@"TraktOAuthCode"];
    double expires = [[NSUserDefaults standardUserDefaults] doubleForKey:@"TraktCodeExpiresIn"];
    
    if(code == nil)
        return NO;
    
    if(expires && expires < [[NSDate date] timeIntervalSince1970])
        code = [[NSUserDefaults standardUserDefaults] stringForKey:@"TraktRefreshCode"];

    if(!expires || expires < [[NSDate date] timeIntervalSince1970])
        [self refreshOAuthToken:code];
    
    return YES;
}

- (void)updateState:(id)aVideo state:(ITVideoPlayerState *)aState {
    
    NSDictionary *params;
    NSDictionary *traktObject;
    NSString *type;
    
    if([aVideo isKindOfClass:[ITTVShow class]]) {
        
        traktObject = [self TVShow:(ITTVShow *)aVideo batch:nil];
        type = @"show";
        
    } else if ([aVideo isKindOfClass:[ITMovie class]]) {
        
        traktObject = [ITMovie traktEntity:aVideo batch:nil];
        type = @"movie";
        
    }
    
    NSString *playerStateString = [ITVideo playerStateString:aState];
    NSDictionary *notification = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:playerStateString, aVideo, nil] forKeys:[NSArray arrayWithObjects:@"state", @"video", nil]];
    
    NSString *url = [NSString stringWithFormat:@"%@/scrobble/%@", kApiUrl, playerStateString];
    
    NSString *appVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSDate *appBuildDate = [ITUtil appBuildDate];
    
    params = [[NSDictionary alloc] initWithObjectsAndKeys:
              traktObject, @"item",
              @"99", @"progress",
              appVersion, @"app_version",
              [appBuildDate descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil], @"app_date",
              nil];

    if([playerStateString isEqualToString:@"stop"])
        [self newTraktQueueEntry:params url:url];
    
    [self callAPI:url WithParameters:params notification:notification];
}

- (void)seen:(NSArray *)videos type:(iTunesEVdK)videoType video:(id)aVideo {
    
    NSDictionary *params;
    NSString *type;
    
    if(videoType == iTunesEVdKTVShow) {
        
        params = [self TVShow:aVideo batch:videos];
        type = @"show/episode";
        
    } else if(videoType == iTunesEVdKMovie) {

        params = [self Movie:nil batch:videos];
        type = @"movie";
    }

    NSString *url = [NSString stringWithFormat:@"%@/%@/seen/%@", kApiUrl, type, [self apiKey]];
    
    [self newTraktQueueEntry:params url:url];
    [self callAPI:url WithParameters:params notification:nil];
}

- (void)library:(NSArray *)videos type:(iTunesEVdK)videoType video:(id)aVideo {
    
    NSDictionary *params;
    NSString *type;
    
    if(videoType == iTunesEVdKTVShow) {
        
        params = [self TVShow:aVideo batch:videos];
        type = @"show/episode";
        
    } else if(videoType == iTunesEVdKMovie) {
        
        params = [self Movie:nil batch:videos];
        type = @"movie";
    }

    NSString *url = [NSString stringWithFormat:@"%@/%@/library/%@", kApiUrl, type, [self apiKey]];
    
    [self callAPI:url WithParameters:params notification:nil];
}

- (NSDictionary *)getSummary:(NSString *)videoType videoId:(NSNumber *)videoId {
    
    return [self getSummary:videoType videoId:videoId season:nil episode:nil];
}

- (NSDictionary *)getSummary:(NSString *)videoType videoId:(NSNumber *)videoId season:(NSNumber *)seasonNumber episode:(NSNumber *)episodeNumber {
    
    NSString *url;
    
    if(!seasonNumber)
        url = [NSString stringWithFormat:@"%@/%@/summary.json/%@/%@", kApiUrl, videoType, [self apiKey], videoId];
    else
       url = [NSString stringWithFormat:@"%@/%@/summary.json/%@/%@/%@/%@", kApiUrl, videoType, [self apiKey], videoId, seasonNumber, episodeNumber];
    
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
    
    NSString *url = [NSString stringWithFormat:@"%@/user/library/%@/watched.json/%@/%@/%@", kApiUrl, type, [self apiKey], self.username, ext];
    
    NSDictionary* headers = [self basicAuthHeaders];
    
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
    
    NSString *url = [NSString stringWithFormat:@"%@/activity/user.json/%@/%@/movie,show,episode/scrobble,seen,checkin/%ld?min=1", kApiUrl, [self apiKey], self.username, (long)lastSync];

    NSDictionary* headers = [self basicAuthHeaders];
    
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
    NSString *uid = [self sha1Hash:[update description]];
    
    NSDictionary *argsDict = [NSDictionary dictionary];
    
    if([update objectForKey:@"type"] != nil && [[update objectForKey:@"type"] isEqualToString:@"episode"]) {

        NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[update objectForKey:@"timestamp"] doubleValue]];
        
        if([update objectForKey:@"episode"] != nil) {

             argsDict = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"uid",[[update objectForKey:@"show"] objectForKey:@"tvdb_id"], @"tvdb_id", [[update objectForKey:@"show"] objectForKey:@"imdb_id" ], @"imdb_id", @"show", @"type",[update objectForKey:@"action"], @"action", [[update objectForKey:@"episode"] objectForKey:@"season"], @"season", [[update objectForKey:@"episode"] objectForKey:@"number"], @"episode", [timestamp descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
            
            NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
            
            [db executeUpdateUsingQueue:qry arguments:argsDict];
            
            //NSLog(@"%@",[db lastErrorMessage]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kITTVShowNeedsUpdateNotification object:nil userInfo:argsDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:kITTVShowEpisodeNeedsUpdateNotification object:nil userInfo:argsDict];
        
        } else if([update objectForKey:@"episodes"] != nil) {
            
            for(NSDictionary *episode in [update objectForKey:@"episodes"]) {
                
                uid = [self sha1Hash:[NSString stringWithFormat:@"%@-%@",uid,episode]];
                
                argsDict = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"uid",[[update objectForKey:@"show"] objectForKey:@"tvdb_id"], @"tvdb_id", [[update objectForKey:@"show"] objectForKey:@"imdb_id" ], @"imdb_id", @"show", @"type",[update objectForKey:@"action"], @"action", [episode objectForKey:@"season"], @"season", [episode objectForKey:@"number"], @"episode", [timestamp descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
                
                NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
                
                [db executeUpdateUsingQueue:qry arguments:argsDict];
                
                //NSLog(@"%@",[db lastErrorMessage]);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kITTVShowEpisodeNeedsUpdateNotification object:nil userInfo:argsDict];
            }
        }    
        
    } else if([update objectForKey:@"movie"] != nil) {
        
        NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[update objectForKey:@"timestamp"] doubleValue]];

        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:uid, @"uid",[[update objectForKey:@"movie"] objectForKey:@"tmdb_id" ], @"tmdb_id", [[update objectForKey:@"movie"] objectForKey:@"imdb_id" ], @"imdb_id", @"movie", @"type", [update objectForKey:@"action"], @"action", [timestamp descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil], @"timestamp", nil];
        
        NSDictionary *dict = [argsDict copy];
        NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"REPLACE" forTable:@"history"];
        
        [db executeUpdateUsingQueue:qry arguments:argsDict];
        
        //NSLog(@"%@",[db lastErrorMessage]);

        [[NSNotificationCenter defaultCenter] postNotificationName:kITMovieNeedsUpdateNotification object:nil userInfo:dict];
    } 
}

- (NSDictionary *)basicAuthHeaders {
    
    /*
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", [self username], [self password]];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"accept", authValue, @"Authorization", nil];
    
    return headers;
     */
    return nil;
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
    
    NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [mParams setObject:@"" forKey:@"password"];
    mParams = [self sortParamsDict:mParams];
    
    NSString *paramsString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:mParams options:0 error:nil] encoding:NSUTF8StringEncoding];

    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:url, @"url", paramsString, @"params", nil];
    
    NSString *qry = [db getInsertQueryFromDictionary:argsDict queryType:@"INSERT" forTable:@"traktQueue"];
    
    [db executeUpdateUsingQueue:qry arguments:argsDict];
    
}

- (void)removeTraktQueueEntry:(NSDictionary *)params url:(NSString *)url {
 
    ITDb *db = [ITDb new];
    
    NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [mParams setObject:@"" forKey:@"password"];
    mParams = [self sortParamsDict:mParams];
    
    NSString *paramsString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:mParams options:0 error:nil] encoding:NSUTF8StringEncoding];
 
    [db executeAndGetResults:@"delete from traktQueue where url=? AND params = ? " arguments:[NSArray arrayWithObjects:url,paramsString, nil]];
    
    NSLog(@"%@",[db lastErrorMessage]);
}

- (void)retryTraktQueue {
    
    ITDb *db = [ITDb new];
    
    NSArray *results = [db executeAndGetResults:@"select * from traktQueue" arguments:nil];
    
    for(NSDictionary *result in results) {
       
        NSDictionary *p = [NSJSONSerialization JSONObjectWithData:[[result objectForKey:@"params"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:p];
        
        [params setObject:[self password] forKey:@"password"];
        
        [self callAPI:[result objectForKey:@"url"] WithParameters:params notification:nil];
    }
}

- (NSMutableDictionary *)sortParamsDict:(NSDictionary *)params {
    
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSMutableDictionary *sortedValues = [NSMutableDictionary dictionary];
    for (NSString *key in sortedKeys)
        [sortedValues setObject:[params objectForKey: key] forKey:key];
    
    return sortedValues;
}

- (void)refreshOAuthToken:(NSString *)code {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/token", kApiUrl]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *httpBody = @"{\"code\": \"%@\", \"client_id\": \"%@\", \"client_secret\": \"%@\", \"redirect_uri\": \"traktable://oauth\", \"grant_type\": \"authorization_code\"}";
    
    httpBody = [NSString stringWithFormat:httpBody, code, [self apiKey], [self apiSecret]];
    
    [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          NSLog(@"ERROR ---> %@", error);
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      //NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      //NSLog(@"Response Body:\n%@\n", body);
                                      
                                      id json = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
                                      
                                      [[NSUserDefaults standardUserDefaults] setObject:[json objectForKey:@"access_token"] forKey:@"TraktOAuthCode"];
                                      [[NSUserDefaults standardUserDefaults] setObject:[json objectForKey:@"refresh_token"] forKey:@"TraktRefreshCode"];
                                      [[NSUserDefaults standardUserDefaults] setDouble:([[NSDate date] timeIntervalSince1970] + [[json objectForKey:@"expires_in"] doubleValue]) - 3600 forKey:@"TraktCodeExpiresIn"];
                                  }];
    [task resume];
}

@end
