//
//  TMDBGenre.h
//  iTMDb
//
//  Created by Alessio Moiso on 16/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDBGenre : NSObject

@property int identifier;
@property NSString *name;

+ (TMDBGenre*)genreWithID:(int)identifier andName:(NSString*)name;

- (id)initWithID:(int)identifier andName:(NSString*)name;

@end
