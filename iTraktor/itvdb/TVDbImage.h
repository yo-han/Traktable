//
//  TVDbImage.h
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVDbClient;

@interface TVDbImage : NSObject
{
    NSString *_url;
}

- (TVDbImage *)initWithUrl:(NSString *)url;
- (NSString *)url;
- (NSString *)thumbnailUrl;

@end