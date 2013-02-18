//
//  TMDBMovieCollection.m
//  iTMDb
//
//  Created by Alessio Moiso on 13/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import "TMDBMovieCollection.h"

#import "TMDB.h"

@implementation TMDBMovieCollection

+ (TMDBMovieCollection*)collectionWithName:(NSString*)name andContext:(TMDB*)context {
    return [[TMDBMovieCollection alloc] initWithName:name andContext:context];
}

- (id)initWithName:(NSString*)aName andContext:(TMDB*)aContext {
    if ([self init]) {
        _results = [NSMutableArray array];
        NSString *aNameEscaped = [aName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1d/search/movie?api_key=%@&language=%@&query=%@",
                                           API_VERSION, aContext.apiKey, aContext.language, aNameEscaped]];
        _context = aContext;
        _request = [TMDBRequest requestWithURL:url delegate:self];
    }
    return self;
}

#pragma mark -
#pragma mark TMDBRequestDelegate

- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error {
    if (error)
	{
		//NSLog(@"iTMDb: TMDBMovie request failed: %@", [error description]);
		if (_context)
			[_context movieDidFailLoading:self error:error];
		return;
	}
    
    _rawResults = [[NSArray alloc] initWithArray:(NSArray *)[[request parsedData] valueForKey:@"results"] copyItems:YES];
    _results = [NSMutableArray arrayWithCapacity:[_rawResults count]];
    for (NSDictionary *movie in _rawResults) {
        TMDBPromisedMovie *proMovie = [TMDBPromisedMovie promisedMovieFromDictionary:movie withCollection:self];
        [_results addObject:proMovie];
    }
    
    if (_context)
		[_context movieDidFinishLoading:self];
}

@end
