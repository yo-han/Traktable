//
//  TVDbClient.m
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import "TVDbClient.h"
#import "XMLReader.h"

@interface TVDbClient()

- (id)initWithLanguage:(NSString *)language;

@end


@implementation TVDbClient

@synthesize apiKey = _apiKey;
@synthesize language = _language;

# pragma mark - singleton

+ (TVDbClient *)sharedInstance
{
    static dispatch_once_t onlyOnceToken = 0;
    __strong static TVDbClient *sharedObject = nil;

    dispatch_once(&onlyOnceToken, ^{
        sharedObject = [[TVDbClient alloc] initWithLanguage: @"en"];
    });
    return sharedObject;
}

# pragma mark - initializers

- (id)initWithLanguage:(NSString *)language
{
    if (self = [super init])
    {
        _language = language;
    }
    return self;
}

#pragma mark - public methods

- (NSDictionary *)requestURL:(NSString *)url
{
    NSMutableData *data     = [NSMutableData data];
    NSString *baseUrl       = [BASE_URI stringByAppendingString:url];

    NSURLRequest *request   = [NSURLRequest requestWithURL:[NSURL URLWithString:baseUrl]];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error          = [[NSError alloc] init];
    NSData *responseData    = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    [data setData:responseData];

    return [XMLReader dictionaryForXMLData:data error:&error];
}

@end
