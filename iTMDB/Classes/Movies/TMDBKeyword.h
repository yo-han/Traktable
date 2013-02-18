//
//  TMDBKeyword.h
//  iTMDb
//
//  Created by Alessio Moiso on 16/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDBKeyword : NSObject

@property int identifier;
@property NSString *name;

+ (TMDBKeyword*)keywordWithID:(int)identifier andName:(NSString*)name;

- (id)initWithID:(int)identifier andName:(NSString*)name;

@end
