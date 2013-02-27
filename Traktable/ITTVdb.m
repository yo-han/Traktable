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
#import "iTVDb/iTVDb.h"

@interface ITTVdb()

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle;
+ (NSString *)checkCache:(NSString *)title;

@end


@implementation ITTVdb

+ (NSString *)getTVDBId:(NSString *)title {
    
    NSLog(@"Looking for show %@ imdbId", title);
    NSString *cachedID = [self checkCache:title];
    NSLog(@"Debug: m1");
    if(cachedID == (id)[NSNull null])
        cachedID = @"";
        NSLog(@"Debug: m2");
    if([cachedID isEqualToString:@""]) {
            NSLog(@"Debug: m3");
        NSDictionary *config = [ITConfig getConfigFile];
            NSLog(@"Debug: m4");
        [[TVDbClient sharedInstance] setApiKey:[config objectForKey:@"tvdbApiKey"]];
            NSLog(@"Debug: m5");
        NSMutableArray *shows = [TVDbShow findByName:title];
            NSLog(@"Debug: m6");
        if([shows count] == 0) {
            
            NSLog(@"Show %@ imdbId not found", title);
            return @"";
        
        } else {
            
            TVDbShow *show = [shows objectAtIndex:0];
            [self setCache:show.imdbId title:title];
            
            NSLog(@"Show %@ imdbId found and cached: %@", title, show.imdbId);
            return show.imdbId;
        }
    } else {
        
        NSLog(@"Show %@ imdbId cached: %@", title, cachedID);
        
        return cachedID;
    }
}

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle {
    
    NSString *dbFilePath = [[ITLibrary applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
    
    [db open];
    [db executeUpdate:@"REPLACE INTO tvdbCache (show, imdbId) VALUES (?,?)", aTitle, imdbId];
    [db close];
}

+ (NSString *)checkCache:(NSString *)title {
    
    NSString *_imdbId;
    NSString *dbFilePath = [[ITLibrary applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
    
    [db open];
    
    FMResultSet *s = [db executeQuery:@"SELECT imdbId FROM tvdbCache WHERE show = ?", title];
    
    if ([s next])
        _imdbId = [s objectForColumnName:@"imdbId"];
    else
        _imdbId = @"";
    
    [db close];
    
    return _imdbId;
}

@end
