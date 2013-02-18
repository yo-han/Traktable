//
//  TMDBKeyword.m
//  iTMDb
//
//  Created by Alessio Moiso on 16/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import "TMDBKeyword.h"

@implementation TMDBKeyword

+ (TMDBKeyword*)keywordWithID:(int)identifier andName:(NSString*)name {
    return [[TMDBKeyword alloc] initWithID:identifier andName:name];
}

- (id)initWithID:(int)identifier andName:(NSString*)name {
    if ([self init]) {
        _identifier = identifier;
        _name = name;
    }
    return self;
}

- (NSString *)description
{
	return self.name;
}

@end
