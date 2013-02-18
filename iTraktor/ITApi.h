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

@class ITTVShow;

@interface ITApi : NSObject

- (void)setPassword:(NSString *)password;
- (BOOL)testAccount;

- (NSString*)username;
- (NSString *)password;

- (void)updateState:(id)aVideo state:(NSString *)aState;
- (void)seen:(NSArray *)videos type:(iTunesEVdK)videoType video:(id)aVideo;

@end
