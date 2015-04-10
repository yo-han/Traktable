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
#import "WebViewController.h"
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
