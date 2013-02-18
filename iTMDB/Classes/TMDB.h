//
//  TMDB.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMDBDelegate.h"
#import "TMDBMovie.h"
#import "TMDBMovieCollection.h"

@interface TMDB : NSObject {
@protected
	id<TMDBDelegate> __unsafe_unretained _delegate;
	NSString *_apiKey;
	NSString *_language;
}

@property (nonatomic, unsafe_unretained) id<TMDBDelegate> delegate;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSDictionary *configuration;

/** @name Creating an Instance */

/**
 * 
 */
- (id)initWithAPIKey:(NSString *)anApiKey delegate:(id<TMDBDelegate>)aDelegate language:(NSString *)aLanguage;

/** @name Notifications */
/**
 * 
 */
- (void)movieDidFinishLoading:(id)aMovie;
/**
 * 
 */
- (void)movieDidFailLoading:(id)aMovie error:(NSError *)error;

/** @name Convenience Methods */
/**
 * Fetches information about the movie with the given TMDb ID.
 *
 * @param anID The ID of the movie to fetch information about.
 * @return A TMDBMovie instance with the current information from the TMDb website.
 */
- (TMDBMovie *)movieWithID:(NSInteger)anID;

/**
 * Fetches information about the movie with the given name.
 *
 * As several movies share the same name, you can pass the year the movie was released to narrow down the search, e.g. "Charlotte's Web (2006)" to get the remake from 2006, rather than the original from 1973.
 *
 * @param aName The name of the movie to fetch information about.
 */
- (TMDBMovieCollection *)movieWithName:(NSString *)aName;

@end