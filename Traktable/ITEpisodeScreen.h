//
//  ITEpisodeScreen.h
//  Traktable
//
//  Created by Johan Kuijt on 30-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITEpisodeScreen : NSObject

typedef enum {
    ITEpisodeScreenSizeSmall,
    ITEpisodeScreenSizeMedium,
    ITEpisodeScreenSizeOriginal
} ITEpisodeScreenSize;

- (NSImage *)getScreen:(NSNumber *)showId season:(NSNumber *)season episode:(NSNumber *)episode withSize:(ITEpisodeScreenSize)size;
- (NSImage *)screen:(NSNumber *)showId season:(NSNumber *)season episode:(NSNumber *)episode withUrl:(NSString *)urlString size:(ITEpisodeScreenSize)size;

@end
