//
//  ITMoviePoster.h
//  Traktable
//
//  Created by Johan Kuijt on 08-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITMoviePoster : NSObject

typedef enum {
    ITMoviePosterSizeSmall,
    ITMoviePosterSizeMedium,
    ITMoviePosterSizeOriginal
} ITMoviePosterSize;

- (NSImage *)poster:(NSNumber *)movieId withUrl:(NSString *)urlString size:(ITMoviePosterSize)size;

@end
