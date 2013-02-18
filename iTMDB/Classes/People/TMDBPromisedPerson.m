//
//  TMDBPerson.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import "TMDBPromisedPerson.h"
#import "TMDBMovie.h"

@implementation TMDBPromisedPerson

@synthesize id=_id, name=_name, character=_character, movie=_movie, job=_job, url=_url, order=_order, castID=_castID, profileURL=_profileURL;

+ (NSArray *)personsWithMovie:(TMDBMovie *)movie personsInfo:(NSArray *)personsInfo
{
	NSMutableArray *persons = [NSMutableArray arrayWithCapacity:[personsInfo count]];

	for (NSDictionary *person in personsInfo)
		[persons addObject:[[TMDBPromisedPerson alloc] initWithMovie:movie personInfo:person]];

	return persons;
}

- (id)initWithMovie:(TMDBMovie *)aMovie personInfo:(NSDictionary *)personInfo
{
	if ((self = [super init]))
	{
		_movie = aMovie;
		_id = [[personInfo objectForKey:@"id"] integerValue];
		_name = [[personInfo objectForKey:@"name"] copy];
		_character = [[personInfo objectForKey:@"character"] copy];
		_job = [[personInfo objectForKey:@"job"] copy];
		_url = [NSURL URLWithString:[personInfo objectForKey:@"url"]];
		_order = [[personInfo objectForKey:@"order"] integerValue];
		_castID = [[personInfo objectForKey:@"cast_id"] integerValue];
		_profileURL = [NSURL URLWithString:[personInfo objectForKey:@"profile"]];
	}
	return self;
}

- (NSString *)description
{
	if (_movie      &&
		_character  && ![_character isKindOfClass:[NSNull class]] && [_character length] > 0 &&
		_name       && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@: %@ as '%@' in '%@' %@>", [self class], _name, _character, _movie.title, _movie.year > 0 ? [NSString stringWithFormat:@" (%li)", _movie.year] : @"", nil];
	else if (_movie &&
			 _name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0      &&
			 _job   && ![_job isKindOfClass:[NSNull class]]       && [_job length] > 0)
		return [NSString stringWithFormat:@"<%@: %@ as %@ of '%@' %@>", [self class], _name, _job, _movie.title, _movie.year > 0 ? [NSString stringWithFormat:@" (%li)", _movie.year] : @"", nil];
	else if (_movie &&
			 _name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@: %@ in '%@' %@>", [self class], _name, _movie.title, _movie.year > 0 ? [NSString stringWithFormat:@" (%li)", _movie.year] : @"", nil];
	else if (_name  && ![_name isKindOfClass:[NSNull class]]      && [_name length] > 0)
		return [NSString stringWithFormat:@"<%@: %@>", [self class], _name, nil];

	return [NSString stringWithFormat:@"<%@>", [self class]];
}


@end