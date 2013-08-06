//
//  ITTVdb.m
//  Traktable
//
//  Created by Johan Kuijt on 14-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTVdb.h"
#import "ITLibrary.h"
#import "ITConfig.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "iTVDb/iTVDb.h"
#import "ITConstants.h"

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
        
        NSDictionary *config = [ITConfig getConfigFile];
        
        [[TVDbClient sharedInstance] setApiKey:[config objectForKey:@"tvdbApiKey"]];
        NSMutableArray *shows = [TVDbShow findByName:title];
        
        if([shows count] == 0) {
            
            NSLog(@"Show %@ imdbId not found", title);
            return @"";
        
        } else {
            
            TVDbShow *show = [shows objectAtIndex:0];
            [self setCache:show.imdbId title:title];
            
            NSLog(@"Show %@ imdbId found and cached: %@", title, show.imdbId);
            return show.imdbId;
        }
        
        return @"";
        
    } else {
        
        NSLog(@"Show %@ imdbId cached: %@", title, cachedID);
        
        return cachedID;
    }
}

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle {
    
    NSString *dbFilePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"REPLACE INTO tvdbCache (show, imdbId) VALUES (%@, %@)", aTitle, imdbId];
    }];
}

+ (NSString *)checkCache:(NSString *)title {
    
    __block NSString *_imdbId = nil;
    NSString *dbFilePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
            
        FMResultSet *s = [db executeQuery:@"SELECT imdbId FROM tvdbCache WHERE show = ?", title];
        
        if ([s next])
            _imdbId = [s objectForColumnName:@"imdbId"];
        else
            _imdbId = @"";
        
        [s close];
    }];
    
    return _imdbId;
}

@end
