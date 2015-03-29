//
//  ITTVdb.m
//  Traktable
//
//  Created by Johan Kuijt on 14-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTVdb.h"
#import "ITConfig.h"
#import "ITDb.h"
#import "iTVDb/iTVDb.h"

@interface ITTVdb()

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle;
+ (NSString *)checkCache:(NSString *)title;

@end

@implementation ITTVdb

+ (NSString *)getTVDBId:(NSString *)title {
    
    NSLog(@"Looking for show %@ imdbId", title);
    NSString *cachedID = [self checkCache:title];
    
    if(cachedID == (id)[NSNull null])
        cachedID = @"";
    
    if([cachedID isEqualToString:@""]) {
        
        ITConfig *config = [ITConfig sharedObject];
        
        [[TVDbClient sharedInstance] setApiKey:[config TVDBApiKey]];
        NSMutableArray *shows = [TVDbShow findByName:title];
        
        if([shows count] == 0) {
            
            NSLog(@"Show %@ imdbId not found", title);
            return @"";
        
        } else {
            
            TVDbShow *show = [shows objectAtIndex:0];
            
            // It's possible that thetvdb has a show but doesn't have the imdbId for it, in that
            // case if we try to cache it, the sql execution will cause an unhandled exception
            
            if (show.imdbId.length > 0) {
                
                [self setCache:show.imdbId title:title];
                
                NSLog(@"Show %@ imdbId found and cached: %@", title, show.imdbId);
                return show.imdbId;
                
            } else {
                
                NSLog(@"Show %@ imdbId not found", title);
                return @"";
                
            }
        }
        
        return @"";
        
    } else {
        
        NSLog(@"Show %@ imdbId cached: %@", title, cachedID);
        
        return cachedID;
    }
}

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle {
    
    ITDb *db = [ITDb new];
    
    NSArray *args = [NSArray arrayWithObjects:aTitle, imdbId, nil];
    
    [db executeUpdateUsingQueue:@"REPLACE INTO tvdbCache (show, imdbId) VALUES (?,?)" arguments:args];
}

+ (NSString *)checkCache:(NSString *)title {
    
    ITDb *db = [ITDb new];
    
    NSDictionary *result = [db executeAndGetOneResult:@"SELECT imdbId FROM tvdbCache WHERE show = ?" arguments:[NSArray arrayWithObject:title]];
    
    NSString *imdbId = @"";
    
    if(result != nil)
        imdbId = [result objectForKey:@"imdbId"];
    
    return imdbId;
}

@end
