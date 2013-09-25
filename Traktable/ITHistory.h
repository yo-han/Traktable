//
//  ITHistory.h
//  Traktable
//
//  Created by Johan Kuijt on 05-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITHistory : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSImage *poster;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *traktUrl;
@property (nonatomic, strong) NSString *episodeTitle;
@property (nonatomic) NSInteger episode;
@property (nonatomic) NSInteger season;

+ (ITHistory *)historyEntityWithHistoryObject:(id)object;
- (NSArray *)fetchMovieHistory;
- (NSArray *)fetchTvShowHistory;

@end
