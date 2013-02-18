//
//  TMDBDelegate.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDB;
@class TMDBMovie;
@class TMDBMovieCollection;

/**
 * An instance that acts as a delegate of `TMDB` objects must implement the `TMDBDelegate` protocol.
 */
@protocol TMDBDelegate <NSObject>

@required

/** @name Loading Notifications */
/**
 * Called when a movie has finished loading.
 *
 * @param context The TMDB context that was used to make the load request.
 * @param movie The loaded movie.
 */
- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)movie;
- (void)tmdb:(TMDB *)context didFinishLoadingMovieCollection:(TMDBMovieCollection *)movie;

/**
 * Called when a movie failed loading.
 *
 * @param context The TMDB context that was used to make the load request.
 * @param movie The movie that failed to load.
 * @param error Information about the loading error.
 */
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error;
- (void)tmdb:(TMDB *)context didFailLoadingMovieCollection:(TMDBMovieCollection *)movie error:(NSError*)error;

@end