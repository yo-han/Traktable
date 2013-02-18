//
//  TVDbClient.h
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASE_URI @"http://www.thetvdb.com/api/"
#define BASE_IMAGE_URI @"http://www.thetvdb.com/"

@class XMLReader;

@interface TVDbClient : NSObject
{
    NSString *_apiKey;
    NSString *_language;
}

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *language;

+ (TVDbClient *)sharedInstance;

- (NSDictionary *)requestURL:(NSString *)url;

@end