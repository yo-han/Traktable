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
#import "EMKeychainItem.h"
#import "ITNotification.h"
#import "Unirest.h"
#import "ITConstants.h"

#define kApiUrl @"http://api.trakt.tv"

@interface ITApi()

- (NSString *)sha1Hash:(NSString *)input;
- (NSString *)apiKey;

- (NSDictionary *)TVShow:(ITTVShow *)aTVShow batch:(NSArray *)aBatch;
- (NSDictionary *)Movie:(ITMovie *)aMovie batch:(NSArray *)aBatch;

- (void)callAPI:(NSString*)apiCall WithParameters:(NSDictionary *)params notification:(NSDictionary *)notification;
- (id)callURLSync:(NSString *)requestUrl withParameters:(NSDictionary *)params;
- (void)callURL:(NSString *)requestUrl withParameters:(NSDictionary *)params completionHandler:(void (^)(id, NSError *))completionBlock;
- (void)callAPISucces:(NSDictionary *)notification;

@end


@implementation ITApi

- (NSString *)sha1Hash:(NSString *)input   {
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
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
    
    if (aTVShow && aBatch == nil) {

        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                  self.username, @"username",
                  self.password, @"password",
                  aTVShow.show, @"title",
                  [NSString stringWithFormat:@"%ld", aTVShow.seasonNumber], @"season",
                  [NSString stringWithFormat:@"%ld", aTVShow.episodeNumber], @"episode",
                  [NSString stringWithFormat:@"%ld", aTVShow.year], @"year",
                  [NSString stringWithFormat:@"%ld", aTVShow.duration], @"duration",
                  @"50", @"progress",
                  appVersion, @"plugin_version",
                  @"1.0", @"media_center_version",
                  @"31.12.2011", @"media_center_date",
                  nil];

    } else if(aTVShow != nil && aBatch != nil){
        
        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                  self.username, @"username",
                  self.password, @"password",
                  aTVShow.show, @"title",
                  [NSNumber numberWithInteger:aTVShow.year], @"year",
                  aBatch, @"episodes",
                  nil];
    } else {
        
        params = [[NSDictionary alloc] initWithObjectsAndKeys:
                  self.username, @"username",
                  self.password, @"password",
                  nil];
        
    }

    
    return params;
}

- (NSDictionary *)Movie:(ITMovie *)aMovie batch:(NSArray *)aBatch {
    
    NSDictionary *params;
    NSString *appVersion = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    if (aMovie && aBatch == nil) {
        
        params = [NSDictionary dictionaryWithObjectsAndKeys:
                  self.username, @"username",
                  self.password, @"password",
                  aMovie.name, @"title",
                  aMovie.imdbId, @"imdb_id",
                  [NSString stringWithFormat:@"%ld", aMovie.year], @"year",
                  [NSString stringWithFormat:@"%ld", aMovie.duration], @"duration",
                  @"50", @"progress",
                  appVersion, @"plugin_version",
                  @"1.0", @"media_center_version",
                  @"31.12.2011", @"media_center_date",
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
    
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"accept", nil];

    HttpJsonResponse* response = [[Unirest post:^(MultipartRequest* request) {
        [request setUrl:requestUrl];
        [request setHeaders:headers];
        [request setParameters:params];
    }] asJson];
    
    id responseObject = [NSJSONSerialization JSONObjectWithData:[response rawBody] options:0 error:nil];
    
    return responseObject;
}

- (void)callURL:(NSString *)requestUrl withParameters:(NSDictionary *)params completionHandler:(void (^)(id , NSError *))completionBlock
{
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"accept", nil];
 
    [[Unirest post:^(MultipartRequest* request) {
        
        [request setUrl:requestUrl];
        [request setHeaders:headers];
        [request setParameters:params];
        
    }] asJsonAsync:^(HttpJsonResponse* response) {
        
        NSError *error;
        id responseObject = [NSJSONSerialization JSONObjectWithData:[response rawBody] options:0 error:&error];

        if(error)
            NSLog(@"API Call JSON error: %@",error);
        
        completionBlock(responseObject, nil);
    }];
}

- (void)callAPI:(NSString*)apiCall WithParameters:(NSDictionary *)params notification:(NSDictionary *)notification {

    [self callURL:apiCall withParameters:params completionHandler:^(id response, NSError *err) {
        
        if(![response isKindOfClass:[NSDictionary class]]) {

            NSLog(@"Repsonse is not an NSDictionary");
            return;
        }
        
        if([[notification objectForKey:@"state"] isEqual: @"scrobble"])
            [self updateHistory:response parameters:params];
        
        if ([[response objectForKey:@"status"] isEqualToString:@"success"]){
            
            NSLog(@"Succes: %@",[response objectForKey:@"message"]);
            
            if(notification != nil)
                [self callAPISucces:notification];
        } else {
            
            NSLog(@"%@ got error: %@", apiCall, response);
        }
        
        if (err) NSLog(@"Error: %@",[err description]);
    }];
}

- (void)callAPISucces:(NSDictionary *)notification {
    
    if([[notification objectForKey:@"state"] isEqual: @"scrobble"])
        [ITNotification showNotification:[NSString stringWithFormat:@"Scrobbled: %@", [notification objectForKey:@"video"]]];
}

- (BOOL)testAccount {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[self username] forKey:@"username"];
    [params setValue:[self password] forKey:@"password"];
    
    NSString *url = [NSString stringWithFormat:@"%@/account/test/%@", kApiUrl, [self apiKey]];
    NSDictionary *data = [self callURLSync:url withParameters:params];

    if([[data objectForKey:@"status"] isEqualToString:@"failure"])
        return NO;
    else
        return YES;
}

- (void)updateState:(id)aVideo state:(NSString *)aState {
    
    NSLog(@"%@ --> %@", [aState stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[aState substringToIndex:1] uppercaseString]], aVideo);
    NSDictionary *params;
    NSString *type;
    
    if([aVideo isKindOfClass:[ITTVShow class]]) {
        params = [self TVShow:(ITTVShow *)aVideo batch:nil];
        type = @"show";
    } else if ([aVideo isKindOfClass:[ITMovie class]]) {
        params = [self Movie:(ITMovie *)aVideo batch:nil];
        type = @"movie";
    }
    
    NSDictionary *notification = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:aState, aVideo, nil] forKeys:[NSArray arrayWithObjects:@"state", @"video", nil]];

    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@", kApiUrl, type, aState, [self apiKey]];
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

- (NSArray *)watchedSync:(iTunesEVdK)videoType extended:(NSString *)ext {
    
    NSString *type;
        
    if(videoType == iTunesEVdKTVShow) {
        
        type = @"shows";
        
    } else if(videoType == iTunesEVdKMovie) {
        
        type = @"movies";
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/user/library/%@/watched.json/%@/%@/%@", kApiUrl, type, [self apiKey], self.username, ext];
    
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"accept", nil];
    
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

- (void)updateHistory:(NSDictionary *)update parameters:(NSDictionary *)params {
      
    ITDb *db = [ITDb new];
    
    if([update objectForKey:@"show"] != nil) {
        
        NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[[update objectForKey:@"show"] objectForKey:@"tvdb_id" ], @"tvdb_id", [[update objectForKey:@"show"] objectForKey:@"imdb_id" ], @"imdb_id", @"show", @"type", [update objectForKey:@"status"], @"success", nil];
        
        [db executeUpdateUsingQueue:@"INSERT INTO history (tvdb_id, imdb_id, type, success, timestamp) VALUES (:tmdb_id, :imdb_id, :type, :success, datetime('now'))" arguments:argsDict];
        //NSLog(@"%@",[db lastErrorMessage]);
        
    } else if([update objectForKey:@"movie"] != nil) {
        
        NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[[update objectForKey:@"movie"] objectForKey:@"tmdb_id" ], @"tmdb_id", [[update objectForKey:@"movie"] objectForKey:@"imdb_id" ], @"imdb_id", @"movie", @"type", [update objectForKey:@"status"], @"success", nil];
        
        [db executeUpdateUsingQueue:@"INSERT INTO history (tmdb_id, imdb_id, type, success, timestamp) VALUES (:tmdb_id, :imdb_id, :type, :success, datetime('now'))" arguments:argsDict];
        //NSLog(@"%@",[db lastErrorMessage]);
        
    } else if([update objectForKey:@"error"] != nil) {
     
        NSString *type = ([params objectForKey:@"season"] != nil) ? @"show" : @"movie";
        
        NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"tmdb_id", [params objectForKey:@"imdb_id" ], @"imdb_id", type, @"type", [update objectForKey:@"status"], @"success", [update objectForKey:@"error"], @"comment", nil];
        
        [db executeUpdateUsingQueue:@"INSERT INTO history (tmdb_id, imdb_id, type, success, comment, timestamp) VALUES (:tmdb_id, :imdb_id, :type, :success, :comment, datetime('now'))" arguments:argsDict];
        
        //NSLog(@"%@",[db lastErrorMessage]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITHistoryNeedsUpdateNotification object:nil];
}

@end
