//
//  ITConfig.m
//  Traktable
//
//  Created by Johan Kuijt on 18-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITConfig.h"

#define kOAuthCode          @"TraktOAuthCode"
#define kOAuthRefreshCode   @"TraktRefreshCode"
#define kTraktCodeExpiresIn @"TraktCodeExpiresIn"
#define kTraktApiKey        @"traktApiKey"
#define kTraktApiSecret     @"traktApiSecret"
#define kTVDBApiKey         @"tvdbApiKey"

@interface ITConfig()

@property(nonatomic, retain) NSDictionary *config;

@end

@implementation ITConfig

+ (instancetype)sharedObject {
    static ITConfig *_sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
        _sharedObject.config = [_sharedObject getConfigFile];
    });
    
    return _sharedObject;
}

- (NSString *)apiKey {
    
    return [self.config objectForKey:kTraktApiKey];
}

- (NSString *)apiSecret {
    
    return [self.config objectForKey:kTraktApiSecret];
}

- (NSString *)TVDBApiKey {
    
    return [self.config objectForKey:kTVDBApiKey];
}

- (NSString *)OAuthCode {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:kOAuthCode];
}

- (NSString *)OAuthRefreshCode {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:kOAuthRefreshCode];
}

- (double) OAuthExpiresIn {
    
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kTraktCodeExpiresIn];
}

- (NSDictionary *)getConfigFile {
    
    NSString *configPath = [NSString stringWithFormat:@"%@/Contents/Resources/config.plist",[[NSBundle mainBundle] bundlePath]];

    NSData *plistData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    
    if(!plist) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Config file is missing."];
        [alert runModal];
    }
    
    return plist;
}

- (void)setOAuthCode:(NSString *)code {

    [[NSUserDefaults standardUserDefaults] setObject:code forKey:kOAuthCode];
    
    self.config = [self getConfigFile];
}

- (void)setOAuthRefreshCode:(NSString *)code {
    
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:kOAuthRefreshCode];
    
    self.config = [self getConfigFile];
}

- (void)setOAuthExpireTime:(double)time {
    
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:kTraktCodeExpiresIn];
    
    self.config = [self getConfigFile];
}

@end
