//
//  ITMovieView.m
//  Traktable
//
//  Created by Johan Kuijt on 25-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITMovieView.h"
#import "ITMovie.h"
#import "ITMoviePoster.h"
#import "ITDb.h"

@implementation ITMovieViewBox

// -------------------------------------------------------------------------------
//	hitTest:aPoint
// -------------------------------------------------------------------------------
- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this NSBox
    return nil;
}

@end

@implementation ITMovieScrollView
@end

@interface ITMovieView()

@property (nonatomic, retain) ITDb *db;

@end

@implementation ITMovieCollectionViewItem

@synthesize moviePoster, movieTitle;


-(id)copyWithZone:(NSZone *)zone
{
	id result = [super copyWithZone:zone];
	
	[NSBundle loadNibNamed:@"MovieCollectionViewItem" owner:result];
	
	return result;
}


- (void)setRepresentedObject:(id)object {
	
    [super setRepresentedObject:	object];
	
	if (object == nil)
		return;
	
	NSDictionary* data	= (NSDictionary*) [self representedObject];
	NSString* title	= (NSString*)[data valueForKey:@"name"];
	NSString* image	= (NSString*)[data valueForKey:@"image"];
    
    NSImage *im = [[ITMoviePoster alloc] poster:[data valueForKey:@"movieId"] withUrl:image size:ITMoviePosterSizeMedium];
    
	self.movieTitle = title;
	self.moviePoster = im;
}

- (void)setSelected:(BOOL)flag {
	[super setSelected:	flag];
	
	NSBox *view	= (NSBox*) [self view];
	NSColor *color;
	NSColor *lineColor;
	
	if (flag) {
		color		= [NSColor selectedControlColor];
		lineColor	= [NSColor blackColor];
		
	} else {
		color		= [NSColor controlBackgroundColor];
		lineColor	= [NSColor controlBackgroundColor];
		
        //		[view setBorderType:NSNoBorder];
	}
	
	[view setBorderColor:lineColor];
	[view setFillColor:color];
}


- (void) awakeFromNib {
	NSBox *view	= (NSBox*) [self view];
	//[view setTitle: @""];
	[view setTitlePosition:NSNoTitle];
	[view setBoxType:NSBoxCustom];
	[view setCornerRadius:8.0];
	[view setBorderType:NSLineBorder];
}

@end

@implementation ITMovieView

@synthesize movies;

- (id)init
{
    self = [super initWithNibName:@"MovieViewController" bundle:nil];
    if (self != nil)
    {
        _db = [ITDb new];
    }
    return self;
}

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{    
    [self setMovies:[self fetchMovies]];
    
    NSSize size = NSMakeSize(200, 300);
    [collectionView setMinItemSize:size];
    [collectionView setMaxItemSize:size];

}

- (NSMutableArray *)fetchMovies {
    
    NSMutableArray *moviesTemp = [NSMutableArray array];
    
    NSArray *results = [self.db executeAndGetResults:@"SELECT * FROM movies ORDER BY title ASC" arguments:nil];
    
    for (NSDictionary *result in results) {
        
        ITMovie *movie = [ITMovie movieWithDatabaseRecord:result];
        
        [moviesTemp addObject:movie];
    }
    
    return moviesTemp;
}

@end
