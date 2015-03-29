//
//  ITTrakt.m
//  Traktable
//
//  Created by Johan Kuijt on 29-03-15.
//  Copyright (c) 2015 Mustacherious. All rights reserved.
//

#import "ITTrakt.h"
#import "ITConfig.h"

@interface ITTrakt()

@property(nonatomic, retain) NSString *baseUrl;
@property(nonatomic, retain) NSString *OAuthCode;
@property(nonatomic, retain) ITConfig *config;

@end

@implementation ITTrakt

+ (instancetype)sharedClient {
    static ITTrakt *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:kITTraktBaseURL];
        _sharedClient.config = [ITConfig sharedObject];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSString *)url {
    
    self.baseUrl = url;
    self.OAuthCode = [NSString stringWithFormat:@"Bearer %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"TraktOAuthCode"]];
    
    return self;
}

- (NSMutableURLRequest *)request:(NSString *)url {
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", self.baseUrl, url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.OAuthCode forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"trakt-api-version"];
    [request setValue:[self.config apiKey] forHTTPHeaderField:@"trakt-api-key"];
    
    return request;
}

- (void)dataTaskWithRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(id , NSError *))completionBlock {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      
                                      if (error) {
                                          
                                          NSLog(@"API Call JSON error: %@. Response body looked like: %@", error, body);
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          
                                          if((long)[(NSHTTPURLResponse *)response statusCode] > 204) {
                                              
                                              NSLog(@"ERROR! Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                              NSLog(@"ERROR! Url: %@", [request.URL description]);
                                              
                                              if((long)[(NSHTTPURLResponse *)response statusCode] != 520)
                                                  NSLog(@"ERROR! Response body: %@", body);
                                              
                                              return;
                                          }
                                      }
                                      
                                      id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
                                      
                                      completionBlock(jsonObject, nil);
                                  }];
    [task resume];
}

- (void)POST:(NSString *)url withParameters:(NSDictionary *)params completionHandler:(void (^)(id , NSError *))completionBlock {
    
    NSMutableURLRequest *request = [self request:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:nil error:nil]];
    
    [self dataTaskWithRequest:request completionHandler:completionBlock];
}

- (void)refreshOAuthToken:(NSString *)code {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                code, @"code",
                                [self.config apiKey], @"client_id",
                                [self.config apiSecret], @"client_secret",
                                @"traktable://oauth", @"redirect_uri",
                                @"authorization_code", @"grant_type",
                            nil];
    
    [self POST:kITTraktOAuthUrl withParameters:params completionHandler:^(id response, NSError *err) {
        
        [self.config setOAuthCode:[response objectForKey:@"access_token"]];
        [self.config setOAuthRefreshCode:[response objectForKey:@"refresh_token"]];
        [self.config setOAuthExpireTime:([[NSDate date] timeIntervalSince1970] + [[response objectForKey:@"expires_in"] doubleValue]) - 3600];
    }];
}

- (BOOL)traktUserAuthenticated {
    
    NSString *code = [self.config OAuthCode];
    NSString *refreshCode = [self.config OAuthRefreshCode];
    double expires = [self.config OAuthExpiresIn];

    if(code == nil) {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        return NO;
    }
    
    if(expires && expires < [[NSDate date] timeIntervalSince1970])
        code = refreshCode;
    
    if(!expires || expires < [[NSDate date] timeIntervalSince1970])
        [self refreshOAuthToken:code];
    
    return YES;
}

@end
