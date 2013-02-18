//
//  TVDbUpdater.h
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/13/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVDbClient, XMLReader;

@interface TVDbUpdater : NSObject

@property (nonatomic, strong) NSString *lastUpdatedAt;

+ (TVDbUpdater *)sharedInstance;

- (NSDictionary *)updates;
- (NSDictionary *)showUpdates;
- (NSDictionary *)episodeUpdates;
- (void)updateLastUpdatedAtTimestamp;

@end