//
//  TMDBPromisedMovie.m
//  iTMDb
//
//  Created by Alessio Moiso on 14/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import "TMDBPromisedMovie.h"
#import "TMDBMovieCollection.h"

@implementation TMDBPromisedMovie

+ (TMDBPromisedMovie*)promisedMovieFromDictionary:(NSDictionary*)movie withCollection:(TMDBMovieCollection*)aCollection {
    return [[TMDBPromisedMovie alloc] initWithContentsOfDictionary:movie fromCollection:aCollection];
}

- (id)initWithContentsOfDictionary:(NSDictionary*)movie fromCollection:(TMDBMovieCollection*)aCollection {
    if ([self init]) {
        _collection = aCollection;
        _rawData = movie;
        
        _adult = [NSNumber numberWithBool:(BOOL)[movie valueForKey:@"adult"]];
        _identifier = [movie valueForKey:@"id"];
        
        if (![[movie valueForKey:@"backdrop_path"] isMemberOfClass:[NSNull class]]) {
            _backdrop = [movie valueForKey:@"backdrop_path"];
        }
        if (![[movie valueForKey:@"backdrop_path"] isMemberOfClass:[NSNull class]]) {
            _poster = [movie valueForKey:@"poster_path"];
        }
        if (![[movie valueForKey:@"original_title"] isMemberOfClass:[NSNull class]]) {
            _originalTitle = [movie valueForKey:@"original_title"];
        }
        if (![[movie valueForKey:@"title"] isMemberOfClass:[NSNull class]]) {
            _title = [movie valueForKey:@"title"];
        }
        if (![[movie valueForKey:@"popularity"] isMemberOfClass:[NSNull class]]) {
            _popularity = [movie valueForKey:@"popularity"];
        }
        if (![[movie valueForKey:@"release_date"] isMemberOfClass:[NSNull class]]) {
            NSDateComponents *date = [[NSDateComponents alloc] init];
            NSArray *components = [[movie valueForKey:@"release_date"] componentsSeparatedByString:@"-"];
            [date setYear:[[components objectAtIndex:0] intValue]];
            [date setMonth:[[components objectAtIndex:1] intValue]];
            [date setDay:[[components objectAtIndex:2] intValue]];
            NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            _releaseDate = [cal dateFromComponents:date];
        }
        if (![[movie valueForKey:@"vote_average"] isMemberOfClass:[NSNull class]]) {
            _rate = [movie valueForKey:@"vote_average"];
        }
    }
    return self;
}

- (TMDBMovie*)movie {
    return [[_collection context] movieWithID:[[self identifier] intValue]];
}

@end
