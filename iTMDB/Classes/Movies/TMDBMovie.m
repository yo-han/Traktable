//
//  TMDBMovie.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import "TMDB.h"
#import "TMDBMovie.h"
#import "TMDBImage.h"
#import "TMDBPromisedPerson.h"
#import "TMDBKeyword.h"
#import "TMDBGenre.h"
#import "TMDBCountry.h"

@interface TMDBMovie ()

- (id)initWithURL:(NSURL *)url context:(TMDB *)context;
- (id)initWithURL:(NSURL *)url context:(TMDB *)context userData:(NSDictionary *)userData;

- (NSArray *)arrayWithImages:(NSArray *)images ofType:(TMDBImageType)type;

@end

@implementation TMDBMovie

@synthesize context=_context,
            rawResults=_rawResults,
            id=_id,
			userData=_userData,
            title=_title,
            released=_released,
            overview=_overview,
            runtime=_runtime,
            tagline=_tagline,
            homepage=_homepage,
            imdbID=_imdbID,
            posters=_posters,
            backdrops=_backdrops,
			language=_language,
			translated=_translated,
			adult=_adult,
			url=_url,
			votes=_votes,
			certification=_certification,
			categories=_categories,
			keywords=_keywords,
			languagesSpoken=_languagesSpoken,
			countries=_countries,
			cast=_cast;
@dynamic year;

#pragma mark -
#pragma mark Constructors

+ (TMDBMovie *)movieWithID:(NSInteger)anID context:(TMDB *)aContext
{
	return [[TMDBMovie alloc] initWithID:anID context:aContext];
}

- (id)initWithURL:(NSURL *)url context:(TMDB *)aContext
{
	return [self initWithURL:url context:aContext userData:nil];
}

- (id)initWithURL:(NSURL *)url context:(TMDB *)aContext userData:(NSDictionary *)userData
{
	if ((self = [self init]))
	{
		_context = aContext;

		_rawResults = nil;

		_id = 0;
		_userData = userData;
		_title = nil;
		_released = nil;
		_overview = nil;
		_runtime = 0;
		_tagline = nil;
		_homepage = nil;
		_imdbID = nil;
		_posters = nil;
		_backdrops = nil;
		_rating = 0;
		_revenue = 0;
		_trailer = nil;
		_studios = nil;
		_originalName = nil;
		_alternativeName = nil;
		_popularity = 0;
		_translated = NO;
		_adult = NO;
		_language = nil;
		_url = nil;
		_votes = 0;
		_certification = nil;
		_categories = nil;
		_keywords = nil;
		_languagesSpoken = nil;
		_countries = nil;
		_cast = nil;
		_version = 0;
		_modified = nil;
		
		// Initialize the fetch request
		_request = [TMDBRequest requestWithURL:url delegate:self];
	}

	return self;
}

- (id)initWithID:(NSInteger)anID context:(TMDB *)aContext
{
    ///3/movie/{id}
    
	NSURL *url = [NSURL URLWithString:[API_URL_BASE stringByAppendingFormat:@"%.1d/movie/%ld?api_key=%@&language=%@&append_to_response=casts,images,keywords",
									   API_VERSION, anID, aContext.apiKey, aContext.language]];
	isSearchingOnly = NO;
	return [self initWithURL:url context:aContext];
}

#pragma mark -

- (NSString *)description
{
	if (!self.title)
		return [NSString stringWithFormat:@"<%@>", [self class], nil];

	if (!self.released)
		return [NSString stringWithFormat:@"<%@: %@>", [self class], self.title, nil];

	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *weekdayComponents = [cal components:NSYearCalendarUnit fromDate:self.released];
	NSInteger year = [weekdayComponents year];

	return [NSString stringWithFormat:@"<%@: %@ (%li)>", [self class], self.title, year, nil];
}

#pragma mark -
- (NSUInteger)year
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:self.released];
    return [comp year];
}

#pragma mark -
#pragma mark TMDBRequestDelegate
- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error
{
	if (error)
	{
		//NSLog(@"iTMDb: TMDBMovie request failed: %@", [error description]);
		if (_context)
			[_context movieDidFailLoading:self error:error];
		return;
	}

	_rawResults = [request parsedData];
    
    NSLog(@"%@", _rawResults);

	if (!_rawResults)
	{
		//NSLog(@"iTMDb: Returned data is NOT a dictionary!\n%@", _rawResults);
		if (_context)
		{
			NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSString stringWithFormat:@"The data source (themoviedb) returned invalid data: %@", _rawResults],
									   NSLocalizedDescriptionKey,
									   nil];
			NSError *failError = [NSError errorWithDomain:@"Invalid data"
													 code:0
												 userInfo:errorDict];
			[_context movieDidFailLoading:self error:failError];
		}
		return;
	}
    
    if (![[_rawResults valueForKey:@"adult"] isMemberOfClass:[NSNull class]]) {
        _adult = [[_rawResults valueForKey:@"adult"] boolValue];
    }
    if (![[_rawResults valueForKey:@"budget"] isMemberOfClass:[NSNull class]]) {
        _budget = [[_rawResults valueForKey:@"budget"] floatValue];
    }
    if (![[_rawResults valueForKey:@"homepage"] isMemberOfClass:[NSNull class]]) {
        _homepage = [_rawResults valueForKey:@"homepage"];
    }
    if (![[_rawResults valueForKey:@"id"] isMemberOfClass:[NSNull class]]) {
        _id = [[_rawResults valueForKey:@"id"] intValue];
    }
    if (![[_rawResults valueForKey:@"imdb_id"] isMemberOfClass:[NSNull class]]) {
        _imdbID = [_rawResults valueForKey:@"imdb_id"];
    }
    if (![[_rawResults valueForKey:@"original_title"] isMemberOfClass:[NSNull class]]) {
        _originalName = [_rawResults valueForKey:@"original_title"];
    }
    if (![[_rawResults valueForKey:@"overview"] isMemberOfClass:[NSNull class]]) {
        _overview = [_rawResults valueForKey:@"overview"];
    }
    if (![[_rawResults valueForKey:@"popularity"] isMemberOfClass:[NSNull class]]) {
        _popularity = [[_rawResults valueForKey:@"popularity"] floatValue];
    }
    if (![[_rawResults valueForKey:@"production_companies"] isMemberOfClass:[NSNull class]]) {
        _studios = [[_rawResults valueForKey:@"production_companies"] copy];
    }
    if (![[_rawResults valueForKey:@"revenue"] isMemberOfClass:[NSNull class]]) {
        _revenue = [[_rawResults valueForKey:@"revenue"] intValue];
    }
    if (![[_rawResults valueForKey:@"runtime"] isMemberOfClass:[NSNull class]]) {
        _runtime = [[_rawResults valueForKey:@"runtime"] intValue];
    }
    if (![[_rawResults valueForKey:@"spoken_languages"] isMemberOfClass:[NSNull class]]) {
        _languagesSpoken = [[_rawResults valueForKey:@"spoken_languages"] copy];
    }
    if (![[_rawResults valueForKey:@"tagline"] isMemberOfClass:[NSNull class]]) {
        _tagline = [_rawResults valueForKey:@"tagline"];
    }
    if (![[_rawResults valueForKey:@"title"] isMemberOfClass:[NSNull class]]) {
        _title = [_rawResults valueForKey:@"title"];
    }
    if (![[_rawResults valueForKey:@"vote_average"] isMemberOfClass:[NSNull class]]) {
        _votes = [[_rawResults valueForKey:@"vote_average"] floatValue];
    }
    
    NSMutableArray *newKeywords = [NSMutableArray array];
    for (NSDictionary *key in [[[_rawResults valueForKey:@"keywords"] valueForKey:@"keywords"] copy]) {
        [newKeywords addObject:[TMDBKeyword keywordWithID:[[key valueForKey:@"id"] intValue] andName:[key valueForKey:@"name"]]];
    }
    _keywords = [newKeywords copy];
    
    NSMutableArray *castAndCrew = [[[_rawResults valueForKey:@"casts"] valueForKey:@"cast"] mutableCopy];
    [castAndCrew addObjectsFromArray:[[[_rawResults valueForKey:@"casts"] valueForKey:@"crew"] mutableCopy]];
    _cast = [TMDBPromisedPerson personsWithMovie:self personsInfo:castAndCrew];
    
    if (![[_rawResults valueForKey:@"release_date"] isMemberOfClass:[NSNull class]]) {
        NSDateComponents *date = [[NSDateComponents alloc] init];
        NSArray *components = [[_rawResults valueForKey:@"release_date"] componentsSeparatedByString:@"-"];
        [date setYear:[[components objectAtIndex:0] intValue]];
        [date setMonth:[[components objectAtIndex:1] intValue]];
        [date setDay:[[components objectAtIndex:2] intValue]];
        [date setHour:0];
        [date setMinute:0];
        [date setSecond:0];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _released = [cal dateFromComponents:date];
    }
    
    _backdrops = [[[_rawResults valueForKey:@"images"] valueForKey:@"backdrops"] copy];
    _posters = [[[_rawResults valueForKey:@"images"] valueForKey:@"posters"] copy];
    
    NSMutableArray *newGenres = [NSMutableArray array];
    for (NSDictionary *key in [[_rawResults valueForKey:@"genres"] copy]) {
        [newGenres addObject:[TMDBGenre genreWithID:[[key valueForKey:@"id"] intValue] andName:[key valueForKey:@"name"]]];
    }
    _genres = [newGenres copy];
    
    NSMutableArray *newCountries = [NSMutableArray array];
    for (NSDictionary *key in [[_rawResults valueForKey:@"production_countries"] copy]) {
        [newCountries addObject:[TMDBCountry countryWithISOCode:[key valueForKey:@"iso_3166_1"] andName:[key valueForKey:@"name"]]];
    }
    _countries = [newCountries copy];
    
    if (_context)
		[_context movieDidFinishLoading:self];
}

#pragma mark - Helper methods
- (NSArray *)arrayWithImages:(NSArray *)theImages ofType:(TMDBImageType)aType {
	NSMutableArray *imageObjects = [NSMutableArray arrayWithCapacity:0];

	// outerImageDict: the TMDb API wraps each image in a wrapper dictionary (e.g. each backdrop has an "images" dictionary)
	for (NSDictionary *outerImageDict in theImages)
	{
		// innerImageDict: the image info (see outerImageDict)
		NSDictionary *innerImageDict = [outerImageDict objectForKey:@"image"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        if (aType == TMDBImageTypePoster) {
            if ([[innerImageDict valueForKey:@"type"] isEqualToString:@"poster"]) {
                [dict setValue:[innerImageDict valueForKey:@"url"] forKey:@"url"];
                [dict setValue:[innerImageDict valueForKey:@"width"] forKey:@"width"];
                [dict setValue:[innerImageDict valueForKey:@"height"] forKey:@"height"];
            }
        }
        else if (aType == TMDBImageTypeBackdrop) {
            if ([[innerImageDict valueForKey:@"type"] isEqualToString:@"backdrop"]) {
                [dict setValue:[innerImageDict valueForKey:@"url"] forKey:@"url"];
                [dict setValue:[innerImageDict valueForKey:@"width"] forKey:@"width"];
                [dict setValue:[innerImageDict valueForKey:@"height"] forKey:@"height"];
            }
        }
        
        [imageObjects addObject:dict];
	}
	return imageObjects;
}

#pragma mark -

@end