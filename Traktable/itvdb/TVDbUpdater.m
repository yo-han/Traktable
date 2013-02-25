//
//  TVDbUpdater.m
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/13/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import "TVDbUpdater.h"
#import "TVDbClient.h"

#import "XMLReader.h"

@interface TVDbUpdater()
    
- (NSString *)requestTimeUrl;
- (NSString *)requestUpdatesUrlSince:(NSString *)timestamp;
- (NSString *)requestShowUpdatesUrlSince:(NSString *)timestamp;
- (NSString *)requestEpisodeUpdatesUrlSince:(NSString *)timestamp;
- (NSString *)requestUpdatesUrlSince:(NSString *)timestamp withType:(NSString *)type;
    
@end


@implementation TVDbUpdater

@synthesize lastUpdatedAt;

# pragma mark - singleton

+ (TVDbUpdater *)sharedInstance
{
    static dispatch_once_t onlyOnceToken = 0;
    __strong static TVDbUpdater *sharedObject = nil;
    
    dispatch_once(&onlyOnceToken, ^{
        sharedObject = [[TVDbUpdater alloc] init];
    });
    return sharedObject;
}

# pragma mark - public methods

- (NSDictionary *)updates
{
    return [[TVDbClient sharedInstance] requestURL:[self requestUpdatesUrlSince:[self lastUpdatedAt]]]; 
}

- (NSDictionary *)showUpdates
{
    NSDictionary *showUpdates = [[TVDbClient sharedInstance] requestURL:[self requestShowUpdatesUrlSince:[self lastUpdatedAt]]];
    return [showUpdates retrieveForPath:@"Items.Series"];
}

- (NSDictionary *)episodeUpdates
{
    NSDictionary *episodeUpdates = [[TVDbClient sharedInstance] requestURL:[self requestEpisodeUpdatesUrlSince:[self lastUpdatedAt]]];
    return [episodeUpdates retrieveForPath:@"Items.Episode"];
}

- (void)updateLastUpdatedAtTimestamp
{
    NSDictionary *dictionary = [[TVDbClient sharedInstance] requestURL:[self requestTimeUrl]];
    self.lastUpdatedAt = [dictionary retrieveForPath:@"Items.Time"];
}
                       
# pragma mark - internal methods
                       
- (NSString *)requestTimeUrl
{
    return [NSString stringWithFormat:@"/Updates.php?type=none"];
}

- (NSString *)requestUpdatesUrlSince:(NSString *)timestamp
{
    return [self requestUpdatesUrlSince:timestamp withType:@"all"];
}

- (NSString *)requestShowUpdatesUrlSince:(NSString *)timestamp
{
    return [self requestUpdatesUrlSince:timestamp withType:@"series"];
}

- (NSString *)requestEpisodeUpdatesUrlSince:(NSString *)timestamp
{
    return [self requestUpdatesUrlSince:timestamp withType:@"episode"];
}

- (NSString *)requestUpdatesUrlSince:(NSString *)timestamp withType:(NSString *)type
{
    return [NSString stringWithFormat:@"/Updates.php?type=%@&time=%@", type, timestamp];
}

@end