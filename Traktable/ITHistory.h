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
@property (nonatomic, strong) NSString *success;
@property (nonatomic, strong) NSString *timestamp;

+ (ITHistory *)historyEntityWithHistoryObject:(id)object;
- (NSArray *)fetchMovieHistory;

@end
