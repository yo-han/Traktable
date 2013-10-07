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
#import "ITConstants.h"

//==============================================================================
// This is the data source object.
@interface myImageObject : NSObject
{
    NSString* path;
}
@end

@implementation myImageObject

// -------------------------------------------------------------------------
//	setPath:path
//
//	The data source object is just a file path representation
// -------------------------------------------------------------------------
- (void)setPath:(NSString*)inPath
{
    if (path != inPath)
        path = inPath;
}

// The required methods of the IKImageBrowserItem protocol.
#pragma mark -
#pragma mark item data source protocol

// -------------------------------------------------------------------------
//	imageRepresentationType:
//
//	Set up the image browser to use a path representation.
// -------------------------------------------------------------------------
- (NSString*)imageRepresentationType
{
	return IKImageBrowserPathRepresentationType;
}

// -------------------------------------------------------------------------
//	imageRepresentation:
//
//	Give the path representation to the image browser.
// -------------------------------------------------------------------------
- (id)imageRepresentation
{
	return path;
}

// -------------------------------------------------------------------------
//	imageUID:
//
//	Use the absolute file path as the identifier.
// -------------------------------------------------------------------------
- (NSString*)imageUID
{
    return path;
}

// -------------------------------------------------------------------------
//	imageTitle:
//
//	Use the last path component as the title.
// -------------------------------------------------------------------------
- (NSString*)imageTitle
{
    return @"huttum";
}

// -------------------------------------------------------------------------
//	imageSubtitle:
//
//	Use the file extension as the subtitle.
// -------------------------------------------------------------------------
- (NSString*)imageSubtitle
{
    return @"dittum";
}

@end

//==============================================================================
@implementation ITMovieView

- (id)init
{
    self = [super initWithNibName:@"MovieViewController" bundle:nil];
    if (self != nil)
    {
    
    }
    return self;
}

// -------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------
- (void)awakeFromNib
{
	// Create two arrays : The first is for the data source representation.
	// The second one contains temporary imported images  for thread safeness.
    images = [NSMutableArray array];
    importedImages = [NSMutableArray array];
    
    // Allow reordering, animations and set the dragging destination delegate.
    [imageBrowser setAnimates:YES];
	
	// customize the appearance
	[imageBrowser setCellsStyleMask:IKCellsStyleTitled | IKCellsStyleOutlined | IKCellsStyleSubtitled];
	
	//-- change default font
	// create a centered paragraph style
	NSMutableParagraphStyle *paraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paraphStyle setAlignment:NSCenterTextAlignment];
	
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName];
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[imageBrowser setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	
	attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
	[attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[imageBrowser setValue:attributes forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];
	
    attributes = [[NSMutableDictionary alloc] init];
	[attributes setObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName];
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];
	[attributes setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	[imageBrowser setValue:attributes forKey:IKImageBrowserCellsSubtitleAttributesKey];
    
	//change intercell spacing
	[imageBrowser setIntercellSpacing:NSMakeSize(10, 10)];
	
	//change selection color
	[imageBrowser setValue:[NSColor colorWithCalibratedRed:1 green:0 blue:0.5 alpha:1.0] forKey:IKImageBrowserSelectionColorKey];
	
	//set initial zoom value
	[imageBrowser setZoomValue:0.5];

    [self fetchMovies];
}

// -------------------------------------------------------------------------
//	updateDatasource:
//
//	This is the entry point for reloading image browser data and triggering setNeedsDisplay.
// -------------------------------------------------------------------------
- (void)updateDatasource
{
    // Update the datasource, add recently imported items.
    [images addObjectsFromArray:importedImages];
	
	// Empty the temporary array.
    [importedImages removeAllObjects];
    
    // Reload the image browser, which triggers setNeedsDisplay.
    [imageBrowser reloadData];
}


#pragma mark -
#pragma mark import images from file system

- (BOOL)isImageFile:(NSString*)filePath
{
	BOOL				isImageFile = NO;
	LSItemInfoRecord	info;
	CFStringRef			uti = NULL;
	
	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)filePath, kCFURLPOSIXPathStyle, FALSE);
	
	if (LSCopyItemInfoForURL(url, kLSRequestExtension | kLSRequestTypeCreator, &info) == noErr)
	{
		// Obtain the UTI using the file information.
		
		// If there is a file extension, get the UTI.
		if (info.extension != NULL)
		{
			uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, info.extension, kUTTypeData);
			CFRelease(info.extension);
		}
        
		// No UTI yet
		if (uti == NULL)
		{
			// If there is an OSType, get the UTI.
			CFStringRef typeString = UTCreateStringForOSType(info.filetype);
			if ( typeString != NULL)
			{
				uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassOSType, typeString, kUTTypeData);
				CFRelease(typeString);
			}
		}
		
		// Verify that this is a file that the ImageIO framework supports.
		if (uti != NULL)
		{
			CFArrayRef  supportedTypes = CGImageSourceCopyTypeIdentifiers();
			CFIndex		i, typeCount = CFArrayGetCount(supportedTypes);
            
			for (i = 0; i < typeCount; i++)
			{
				if (UTTypeConformsTo(uti, (CFStringRef)CFArrayGetValueAtIndex(supportedTypes, i)))
				{
					isImageFile = YES;
					break;
				}
			}
            
            CFRelease(supportedTypes);
            CFRelease(uti);
		}
	}
    
    CFRelease(url);
	
	return isImageFile;
}

- (void)addAnImageWithPath:(NSString*)path
{
	BOOL addObject = NO;
	
	NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	if (fileAttribs)
	{
		// Check for packages.
		if ([NSFileTypeDirectory isEqualTo:[fileAttribs objectForKey:NSFileType]])
		{
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:path] == NO)
				addObject = YES;	// If it is a file, it's OK to add.
		}
		else
		{
			addObject = YES;	// It is a file, so it's OK to add.
		}
	}
	
	if (addObject && [self isImageFile:path])
	{
		// Add a path to the temporary images array.
		myImageObject* p = [[myImageObject alloc] init];
		[p setPath:path];
		[importedImages addObject:p];
	}
}

#pragma mark -
#pragma mark IKImageBrowserDataSource

// Implement the image browser  data source protocol .
// The data source representation is a simple mutable array.

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView*)view
{
    return [images count];
}

- (id)imageBrowser:(IKImageBrowserView *) view itemAtIndex:(NSUInteger) index
{
    return [images objectAtIndex:index];
}

- (NSMutableArray *)fetchMovies {

    NSMutableArray *moviesTemp = [NSMutableArray array];
    
    ITDb *db = [ITDb new];
    
    NSArray *results = [db executeAndGetResults:@"SELECT * FROM movies ORDER BY title ASC" arguments:nil];
    
    for (NSDictionary *result in results) {
        
        ITMovie *movie = [ITMovie movieWithDatabaseRecord:result];
        
        [moviesTemp addObject:movie];
        
        NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/movies/%@/medium.jpg", movie.movieId]];
        
        [self addAnImageWithPath:imagePath];
    }
    
    [self updateDatasource];
    [self.view layoutSubtreeIfNeeded];
    
    return moviesTemp;
}

@end
