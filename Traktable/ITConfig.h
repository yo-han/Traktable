//
//  ITConfig.h
//  Traktable
//
//  Created by Johan Kuijt on 18-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITConfig : NSObject

+ (instancetype)sharedObject;

- (NSString *)apiKey;
- (NSString *)apiSecret;

- (NSString *)TVDBApiKey;

- (NSString *)OAuthCode;
- (NSString *)OAuthRefreshCode;
- (double)OAuthExpiresIn;

- (void)setOAuthCode:(NSString *)code;
- (void)setOAuthRefreshCode:(NSString *)code;
- (void)setOAuthExpireTime:(double)time;

@end
