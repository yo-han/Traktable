//
//  IMDB.m
//  Traktable
//
//  Created by Johan Kuijt on 13-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "IMDB.h"
#import "ITLibrary.h"
#import "FMDatabase.h"

@interface IMDB()

+ (NSString * )callAPI:(NSString *)title year:(NSString *)aYear;
+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle;
+ (NSString *)checkCache:(NSString *)title;

@end

@implementation IMDB

+ (NSString * )callAPI:(NSString *)title year:(NSString *)aYear {

    NSString *requestUrl = [NSString stringWithFormat:@"http://www.omdbapi.com/?t=%@&y=%@", [title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], aYear];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod: @"GET"];
    
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    if(data == nil)
        return @"";
    
    NSError *errorJSON;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJSON];

    if([[responseDict objectForKey:@"Response"] isEqualToString:@"False"]) {
        return @"";
    } else {
        NSString *responseD = [responseDict objectForKey:@"imdbID"];
        
        if(responseD == nil)
            return @"";
        
        return responseD;
    }
}

+ (NSString * )getImdbIdByTitle:(NSString *)title year:(NSString *)aYear {

    NSString *cachedID = [self checkCache:title];
    NSLog(@"Looking for movie %@ imdbId", title);
    
    if(cachedID == (id)[NSNull null])
        cachedID = @"";
    
    if([cachedID isEqualToString:@""]) {
        
        /* Off for now
         
        NSString * imdbId = [self callAPI:title year:aYear];
        
        if([imdbId isEqualToString:@""]) {
          
            NSLog(@"No movie %@ imdbId found", title);
            return @"";
        
        } else {

            [self setCache:imdbId title:title];
            NSLog(@"movie %@ imdbId found and cached: %@", title, cachedID);
            
            return imdbId;
        }
         */
        return @"";
        
    } else {
        
        NSLog(@"movie %@ imdbId cached: %@", title, cachedID);
        
        return cachedID;
    }
}

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle {
    
    NSString *dbFilePath = [[ITLibrary applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
   
    [db open];
    [db executeUpdate:@"REPLACE INTO imdb (movie, imdbId) VALUES (?,?)", aTitle, imdbId];
    NSLog(@"%@", [db lastErrorMessage]);
    [db close];
    
}

+ (NSString *)checkCache:(NSString *)title {
    
    NSString *imdbId;
    NSString *dbFilePath = [[ITLibrary applicationSupportFolder] stringByAppendingPathComponent:@"iTraktor.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
    
    [db open];
    
    FMResultSet *s = [db executeQuery:@"SELECT imdbId FROM imdb WHERE movie = ?", title];
    
    if ([s next])
        imdbId = [s objectForColumnName:@"imdbId"];
    else
        imdbId = @"";
    
    [db close];
    
    if(imdbId == nil)
        imdbId = @"";
    
    return imdbId;
}

@end
