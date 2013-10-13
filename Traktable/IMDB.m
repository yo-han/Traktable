//
//  IMDB.m
//  Traktable
//
//  Created by Johan Kuijt on 13-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "IMDB.h"
#import "ITDb.h"

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
    
    id responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if([responseDict isKindOfClass:[NSDictionary class]]) {
        
        if([[responseDict objectForKey:@"Response"] isEqualToString:@"False"]) {
            return @"";
        } else {
            NSString *responseD = [responseDict objectForKey:@"imdbID"];
            
            if(responseD == nil)
                return @"";
            
            return responseD;
        }
    }
    
    return @"";
}

+ (NSString * )getImdbIdByTitle:(NSString *)title year:(NSString *)aYear {

    NSString *cachedID = [self checkCache:title];
    NSLog(@"Looking for movie %@ (%@) imdbId", title, aYear);
    
    if(cachedID == (id)[NSNull null])
        cachedID = @"";
    
    if([cachedID isEqualToString:@""]) {
         
        NSString * imdbId = [self callAPI:title year:aYear];
        
        if([imdbId isEqualToString:@""]) {
          
            NSLog(@"No movie %@ imdbId found", title);
            return @"";
        
        } else {

            [self setCache:imdbId title:title];
            NSLog(@"movie %@ imdbId found and cached: %@", title, cachedID);
            
            return imdbId;
        }
         
        return @"";
        
    } else {
        
        NSLog(@"movie %@ imdbId cached: %@", title, cachedID);
        
        return cachedID;
    }
}

+ (void)setCache:(NSString *)imdbId title:(NSString *)aTitle {
    
    ITDb *db = [ITDb new];
    
    NSArray *args = [NSArray arrayWithObjects:aTitle, imdbId, nil];
    
    [db executeUpdateUsingQueue:@"REPLACE INTO imdb (movie, imdbId) VALUES (?,?)" arguments:args];

}

+ (NSString *)checkCache:(NSString *)title {
    
    ITDb *db = [ITDb new];
    
    NSDictionary *result = [db executeAndGetOneResult:@"SELECT imdbId FROM imdb WHERE movie = ?" arguments:[NSArray arrayWithObject:title]];

    NSString *imdbId = @"";

    if(result != nil)
        imdbId = [result objectForKey:@"imdbId"];
        
    return imdbId;
}

@end
