//
//  TestAppDelegate.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <iTMDb/iTMDb.h>

@interface TestAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, TMDBDelegate, TMDBImageDelegate> {
	TMDB *tmdb;
	TMDBMovie *movie;
    TMDBMovieCollection *movieCollection;
    TMDBImage *example;

	NSDictionary *allData;

	// IBOutlets
	IBOutlet NSWindow *window;
	IBOutlet NSWindow *allDataWindow;
    IBOutlet NSWindow *multipleMovies;
    
    IBOutlet NSArrayController *multipleMoviesController;

	IBOutlet NSTextField *apiKey;
	IBOutlet NSTextField *movieID;
	IBOutlet NSTextField *movieName;
	IBOutlet NSTextField *language;

	IBOutlet NSTextField *movieTitle;
	IBOutlet NSTextView  *movieOverview;
	IBOutlet NSTokenField*movieKeywords;
    IBOutlet NSTokenField*movieGenres;
    IBOutlet NSTokenField*movieCountries;
	IBOutlet NSTextField *movieRuntime;
	IBOutlet NSTextField *movieReleaseDate;
	IBOutlet NSTextField *moviePostersCount;
	IBOutlet NSTextField *movieBackdropsCount;

    IBOutlet NSImageView *moviePoster;
    
	IBOutlet NSButton *goButton;
	IBOutlet NSProgressIndicator *throbber;
	IBOutlet NSButton *viewAllDataButton;

	IBOutlet NSTextView *allDataTextView;
}

@property (nonatomic, strong, readonly) NSWindow *window;

@property (strong) NSMutableArray *multipleMoviesArray;

- (IBAction)go:(id)sender;
- (IBAction)viewAllData:(id)sender;
- (IBAction)loadSelectedPromisedMovie:(id)sender;
- (IBAction)loadExamplePoster:(id)sender;

@end