//
//  TMDB.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import "TMDB.h"

@implementation TMDB

@dynamic apiKey;
@synthesize delegate=_delegate, language=_language;

- (id)initWithAPIKey:(NSString *)anApiKey delegate:(id<TMDBDelegate>)aDelegate language:(NSString *)aLanguage
{
	_delegate = aDelegate;
	_apiKey = [anApiKey copy];
	if (!aLanguage || [aLanguage length] == 0)
		_language = @"en";
	else
		_language = [aLanguage copy];

	return self;
}

#pragma mark -
#pragma mark Notifications
- (void)movieDidFinishLoading:(id)aMovie
{
	if (_delegate) {
        if ([aMovie isMemberOfClass:[TMDBMovieCollection class]]) {
            [_delegate tmdb:self didFinishLoadingMovieCollection:aMovie];
        }
        else {
            [_delegate tmdb:self didFinishLoadingMovie:aMovie];
        }
    }
}

- (void)movieDidFailLoading:(id)aMovie error:(NSError *)error
{
	if (_delegate) {
        if ([aMovie isMemberOfClass:[TMDBMovieCollection class]]) {
            [_delegate tmdb:self didFailLoadingMovieCollection:aMovie error:error];
        }
        else {
            [_delegate tmdb:self didFailLoadingMovie:aMovie error:error]; 
        }
    }
}

#pragma mark -
#pragma mark Shortcuts
- (TMDBMovie *)movieWithID:(NSInteger)anID
{
	return [TMDBMovie movieWithID:anID context:self];
}

- (TMDBMovieCollection *)movieWithName:(NSString *)aName
{
	return [TMDBMovieCollection collectionWithName:aName andContext:self];
}

#pragma mark -
#pragma mark Getters and setters
- (NSString *)apiKey
{
	return _apiKey;
}

- (void)setApiKey:(NSString *)newKey
{
	// TODO: Invalidate active token
	_apiKey = [newKey copy];
}

#pragma mark -

@end