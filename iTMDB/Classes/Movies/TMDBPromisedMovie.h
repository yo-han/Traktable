//
//  TMDBPromisedMovie.h
//  iTMDb
//
//  Created by Alessio Moiso on 14/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMDBDelegate.h"

@interface TMDBPromisedMovie : NSObject

@property NSString *title;
@property NSNumber *adult;
@property NSNumber *identifier;
@property NSString *originalTitle;
@property NSDate *releaseDate;
@property NSNumber *popularity;
@property NSString *backdrop;
@property NSString *poster;
@property NSNumber *rate;
@property NSDictionary *rawData;
@property TMDBMovieCollection *collection;

+ (TMDBPromisedMovie*)promisedMovieFromDictionary:(NSDictionary*)movie withCollection:(TMDBMovieCollection*)aCollection;
- (id)initWithContentsOfDictionary:(NSDictionary*)movie fromCollection:(TMDBMovieCollection*)aCollection;

- (TMDBMovie*)movie;

@end
