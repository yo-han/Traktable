//
//  TVDbImage.m
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import "TVDbImage.h"
#import "TVDbClient.h"

@implementation TVDbImage

#pragma mark - initializers

- (TVDbImage *)initWithUrl:(NSString *)url
{
    if (self = [super init])
    {
        _url = url;
    }
    return self;
}

#pragma mark - public methods

- (NSString *)url
{
    return [BASE_IMAGE_URI stringByAppendingString:_url];
}

- (NSString *)thumbnailUrl
{
    return [BASE_IMAGE_URI stringByAppendingString:[NSString stringWithFormat:@"banners/_cache/%@", _url]];
}

@end