//
//  ITTVShowPoster.h
//  Traktable
//
//  Created by Johan Kuijt on 26-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITTVShowPoster : NSObject

typedef enum {
    ITTVShowPosterSizeSmall,
    ITTVShowPosterSizeMedium,
    ITTVShowPosterSizeOriginal
} ITTVShowPosterSize;

- (NSImage *)getPoster:(NSNumber *)showId withSize:(ITTVShowPosterSize)size;
- (NSImage *)poster:(NSNumber *)showId withUrl:(NSString *)urlString size:(ITTVShowPosterSize)size;

@end
