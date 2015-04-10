//
//  trakt.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#import "iTunes.h"
#import "ITVideo.h"

@class ITTVShow;

@interface ITApi : NSObject

- (void)updateState:(id)aVideo state:(ITVideoPlayerState *)aState;
- (void)batch:(NSDictionary *)videos;

- (void)retryTraktQueue;

@end
