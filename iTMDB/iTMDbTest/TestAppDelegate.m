//
//  TestAppDelegate.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import "TestAppDelegate.h"

@implementation TestAppDelegate

@synthesize window;

+ (void)initialize
{
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"", @"appKey",
							  [NSNumber numberWithInteger:0], @"movieID",
							  @"", @"movieName",
							  @"", @"language",
							  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)awakeFromNib
{
	tmdb = nil;

	NSFont *font = [NSFont fontWithName:@"Lucida Console" size:11.0];
	if (!font)
		font = [NSFont fontWithName:@"Courier" size:11.0];
	[allDataTextView setFont:font];
}

#pragma mark -
- (IBAction)go:(id)sender
{
	[[NSUserDefaults standardUserDefaults] synchronize];

	if (!([[apiKey stringValue] length] > 0 && ([movieID integerValue] > 0 || [[movieName stringValue] length] > 0)))
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Missing either API key, movie ID or title"
										 defaultButton:@"OK"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Please enter both API key, and a movie ID or title.\n\n"
													   @"You can obtain an API key from themoviedb.org."];
		[alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];

		return;
	}

	[throbber startAnimation:self];
	[goButton setEnabled:NO];
	[viewAllDataButton setEnabled:NO];

	if (!tmdb)
		tmdb = [[TMDB alloc] initWithAPIKey:[apiKey stringValue] delegate:self language:nil];

	if (allData)
	{
		allData = nil;
	}

	NSString *lang = [language stringValue];
	if (lang && [lang length] > 0)
		[tmdb setLanguage:lang];
	else
		[tmdb setLanguage:@"en"];

	if ([movieID integerValue] > 0)
		movie = [tmdb movieWithID:[movieID integerValue]];
	else
		movieCollection = [tmdb movieWithName:[movieName stringValue]];
}

- (IBAction)viewAllData:(id)sender
{
	if (!allData)
		return;

	[allDataTextView setString:[allData description]];

	[allDataWindow makeKeyAndOrderFront:self];
}

- (IBAction)loadSelectedPromisedMovie:(id)sender {
    if ([[multipleMoviesController selectedObjects] count] > 0) {
        TMDBPromisedMovie *mov = [[multipleMoviesController selectedObjects] objectAtIndex:0];
        movie = [mov movie];
    }
}

- (IBAction)loadExamplePoster:(id)sender {
    example = [TMDBImage imageWithDictionary:[[movie posters] objectAtIndex:0] context:tmdb delegate:self];
}

- (void)tmdbImage:(TMDBImage*)image didFinishLoading:(NSImage*)aImage inContext:(TMDB*)context {
    [moviePoster setImage:aImage];
}

#pragma mark -
#pragma mark TMDBDelegate

- (void)tmdb:(TMDB *)context didFinishLoadingMovie:(TMDBMovie *)aMovie
{
	printf("%s\n", [[aMovie description] UTF8String]);
    
    [NSApp endSheet:multipleMovies];
    [multipleMovies orderOut:self];
    
	[throbber stopAnimation:self];
	[goButton setEnabled:YES];
	[viewAllDataButton setEnabled:YES];

	allData = [[NSDictionary alloc] initWithDictionary:aMovie.rawResults copyItems:YES];

	[movieTitle setStringValue:aMovie.title ? : @""];
	[movieOverview setString:aMovie.overview ? : @""];
	[movieRuntime setStringValue:[NSString stringWithFormat:@"%lu", aMovie.runtime] ? : @""];

	[movieKeywords setStringValue:[aMovie.keywords componentsJoinedByString:@", "] ? : @""];
    [movieGenres setStringValue:[aMovie.genres componentsJoinedByString:@", "] ? : @""];
    [movieCountries setStringValue:[aMovie.countries componentsJoinedByString:@", "] ? : @""];

	NSDateFormatter *releaseDateFormatter = [[NSDateFormatter alloc] init];
	[releaseDateFormatter setDateFormat:@"dd-MM-yyyy"];
	[movieReleaseDate setStringValue:[releaseDateFormatter stringFromDate:aMovie.released] ? : @""];

	[moviePostersCount setStringValue:[NSString stringWithFormat:@"%lu", [aMovie.posters count]]];
	[movieBackdropsCount setStringValue:[NSString stringWithFormat:@"%lu", [aMovie.backdrops count]]];
}

- (void)tmdb:(TMDB *)context didFinishLoadingMovieCollection:(TMDBMovieCollection *)aMovie {
    self.multipleMoviesArray = [NSMutableArray array];
    for (TMDBPromisedMovie *proM in [aMovie results]) {
        [multipleMoviesController addObject:proM];
    }
    
    [NSApp beginSheet:multipleMovies modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)tmdb:(TMDB *)context didFailLoadingMovieCollection:(TMDBMovieCollection *)movie error:(NSError*)error {
    
}
		
- (void)tmdb:(TMDB *)context didFailLoadingMovie:(TMDBMovie *)movie error:(NSError *)error
{
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];

	[movieTitle setStringValue:@""];
	[movieOverview setString:@""];
	[movieRuntime setStringValue:@"0"];
	[movieReleaseDate setStringValue:@"00-00-0000"];
	[moviePostersCount setStringValue:@"0 (0 sizes total)"];
	[movieBackdropsCount setStringValue:@"0 (0 sizes total)"];

	[throbber stopAnimation:self];
	[goButton setEnabled:YES];

	[viewAllDataButton setEnabled:NO];

}

#pragma mark -
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end