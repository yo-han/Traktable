//
//  MainWindowController.m
//  Traktable
//
//  Created by Johan Kuijt on 28-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "MainWindowController.h"
#import "SourceListItem.h"
#import "ITConstants.h"
#import "ITToolbar.h"
#import "ITHistoryView.h"
#import "ITErrorView.h"
#import "ITQueueView.h"
#import "ITMovieView.h"
#import "ITTVShowView.h"
#import "ITSync.h"

static float const kSidebarWidth = 220.0f;

@interface MainWindowController ()

@property (nonatomic, strong) NSMutableArray *sourceListItems;
@property (nonatomic, strong) NSViewController *currentViewController;
@property (nonatomic, strong) ITHistoryView *historyViewController;
@property (nonatomic, strong) ITMovieView *movieViewController;
@property (nonatomic, strong) ITTVShowView *tvShowViewController;
@property (nonatomic, strong) ITErrorView *errorViewController;
@property (nonatomic, strong) ITQueueView *queueViewController;

@end

@implementation MainWindowController

@synthesize placeholderView=_placeholderView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    _historyViewController = [[ITHistoryView alloc] init];
    _errorViewController = [[ITErrorView alloc] init];
    _queueViewController = [[ITQueueView alloc] init];
    _movieViewController = [[ITMovieView alloc] init];
    _tvShowViewController = [[ITTVShowView alloc] init];
    
    [self switchView:@"movies"];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    if([ud integerForKey:@"TraktableStartUpNum"] > 2 && ![ud boolForKey:@"TraktableDonateAlertShown"])
    {
        [ud setBool:YES forKey:@"TraktableDonateAlertShown"];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Donate"];
        [alert addButtonWithTitle:@"No thanks"];
        [alert setMessageText:@"Please donate"];
        [alert setInformativeText:@"The software is free but if you like it and find it useful, please consider donating..."];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {

            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://yo-han.github.io/Traktable/donate.html"]];
        }
    }
}

- (void)awakeFromNib
{	
	_sourceListItems = [[NSMutableArray alloc] init];
	
    SourceListItem *traktable = [SourceListItem itemWithTitle:NSLocalizedString(@"Traktable", nil) identifier:@"traktable"];
	[traktable setIcon:[NSImage imageNamed:@"movies.png"]];
    
    SourceListItem *moviesItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Movies", nil) identifier:@"movies"];
	[moviesItem setIcon:[NSImage imageNamed:@"movies.png"]];
    
    SourceListItem *tvshowItem = [SourceListItem itemWithTitle:NSLocalizedString(@"TV Shows", nil) identifier:@"tvshows"];
	[tvshowItem setIcon:[NSImage imageNamed:@"movies.png"]];
    
	SourceListItem *historyItem = [SourceListItem itemWithTitle:NSLocalizedString(@"History", nil) identifier:@"history"];
	[historyItem setIcon:[NSImage imageNamed:@"movies.png"]];
	
    SourceListItem *logItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Log", nil) identifier:@"log"];
    [logItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
    SourceListItem *errorItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Errors", nil) identifier:@"errors"];
    [errorItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
    SourceListItem *queueItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Scrobble queue", nil) identifier:@"queue"];
    [queueItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
	
    [traktable setChildren:[NSArray arrayWithObjects:moviesItem, tvshowItem, historyItem, nil]];
    [logItem setChildren:[NSArray arrayWithObjects:errorItem, queueItem, nil]];
	
	[self.sourceListItems addObject:traktable];
    [self.sourceListItems addObject:logItem];
	
	[self.sourceList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
    [self.splitView setPosition:kSidebarWidth ofDividerAtIndex:0];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSUInteger startupTime = 0;
    
    if([ud integerForKey:@"TraktableStartUpNum"]) {
        startupTime = [ud integerForKey:@"TraktableStartUpNum"];
    }
    
    [ud setInteger:(startupTime + 1) forKey:@"TraktableStartUpNum"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:kITUpdateProgressNotification object:nil];
    
    [self.progressLabel setStringValue:@"test"];
}

- (void)switchView:(NSString *)identifier {
    
    NSDictionary *identifiers = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInteger:ITMovies],@"movies",
                                 [NSNumber numberWithInteger:ITTVShows],@"tvshows",
                                 [NSNumber numberWithInteger:ITHistoryMovies],@"history",
                                 [NSNumber numberWithInteger:ITErrorList],@"errors",
                                 [NSNumber numberWithInteger:ITQueueList],@"queue",
                                 nil];

    switch ([[identifiers objectForKey:identifier] intValue]) {
        case ITHistoryMovies:
        case ITHistoryTVShows:
            _currentViewController = self.historyViewController;
            [self.historyViewController refreshTableData:nil];

            [self.bottomBarButton setHidden:YES];
            break;
        case ITErrorList:
            _currentViewController = self.errorViewController;
            [self.errorViewController refreshTableData:ITErrorList];
            
            [self.bottomBarButton setTitle:NSLocalizedString(@"Clear errors", nil)];
            [self.bottomBarButton setHidden:NO];
            [self.bottomBarButton setAction:@selector(clearErrors:)];
            
            break;
        case ITQueueList:
            _currentViewController = self.queueViewController;
            [self.queueViewController refreshTableData:ITQueueList];
            
            [self.bottomBarButton setTitle:NSLocalizedString(@"Clear queue", nil)];
            [self.bottomBarButton setHidden:NO];
            [self.bottomBarButton setAction:@selector(clearQueue:)];
            
            break;
        case ITMovies:
            _currentViewController = self.movieViewController;
            
            [self.bottomBarButton setHidden:YES];
            break;
        case ITTVShows:
            _currentViewController = self.tvShowViewController;
            
            [self.bottomBarButton setHidden:YES];
            
            break;
        default:
            _currentViewController = self.movieViewController;
            
            [self.bottomBarButton setHidden:YES];
            
    }
    
    NSView *view = [self.currentViewController view];
    
    for(NSView *subview in [self.placeholderView subviews]) {
        [subview removeFromSuperview];
    }
    
    [self.placeholderView addSubview:view];
    
    NSRect newBounds;
    newBounds.origin.x = 0;
    newBounds.origin.y = 0;
    newBounds.size.width = [[view superview] frame].size.width;
    newBounds.size.height = [[view superview] frame].size.height - 1;
    [view setFrame:[[view superview] frame]];
    
    // make sure our added subview is placed and resizes correctly
    [view setFrameOrigin:NSMakePoint(0,0)];
    [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
}

#pragma mark -
#pragma mark Splitview Delegate Methods

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(NSInteger)index
{
    CGFloat constrainedCoordinate = proposedCoordinate;
    if (index == 0)
    {
		constrainedCoordinate = kSidebarWidth;
    }
    return constrainedCoordinate;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedCoordinate ofSubviewAt:(NSInteger)index
{
    CGFloat constrainedCoordinate = proposedCoordinate;
    if (index == 0)
	{
		constrainedCoordinate = kSidebarWidth;
    }
	
    return constrainedCoordinate;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    
    return kSidebarWidth;
}

-(void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    CGFloat dividerThickness = [sender dividerThickness];
    NSRect leftRect  = [[[sender subviews] objectAtIndex:0] frame];
    NSRect rightRect = [[[sender subviews] objectAtIndex:1] frame];
    NSRect newFrame  = [sender frame];
    
    leftRect.size.height = newFrame.size.height;
    leftRect.origin = NSMakePoint(0, 0);
    rightRect.size.width = newFrame.size.width - leftRect.size.width - dividerThickness;
    rightRect.size.height = newFrame.size.height;
    rightRect.origin.x = leftRect.size.width + dividerThickness;
    
    [[[sender subviews] objectAtIndex:0] setFrame:leftRect];
    [[[sender subviews] objectAtIndex:1] setFrame:rightRect];
}

#pragma mark -
#pragma mark Source List Data Source Methods

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
	//Works the same way as the NSOutlineView data source: `nil` means a parent item
	if(item==nil) {
		return [self.sourceListItems count];
	}
	else {
		return [[item children] count];
	}
}


- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
	//Works the same way as the NSOutlineView data source: `nil` means a parent item
	if(item==nil) {
		return [self.sourceListItems objectAtIndex:index];
	}
	else {
		return [[item children] objectAtIndex:index];
	}
}


- (id)sourceList:(PXSourceList*)aSourceList objectValueForItem:(id)item
{
	return [item title];
}


- (void)sourceList:(PXSourceList*)aSourceList setObjectValue:(id)object forItem:(id)item
{
	[item setTitle:object];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item
{
	return [item hasChildren];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasBadge:(id)item
{
	return [item hasBadge];
}


- (NSInteger)sourceList:(PXSourceList*)aSourceList badgeValueForItem:(id)item
{
	return [item badgeValue];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasIcon:(id)item
{
	return [item hasIcon];
}


- (NSImage*)sourceList:(PXSourceList*)aSourceList iconForItem:(id)item
{
	return [item icon];
}

- (NSMenu*)sourceList:(PXSourceList*)aSourceList menuForEvent:(NSEvent*)theEvent item:(id)item
{
	if ([theEvent type] == NSRightMouseDown || ([theEvent type] == NSLeftMouseDown && ([theEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask)) {
		NSMenu * m = [[NSMenu alloc] init];
		if (item != nil) {
			[m addItemWithTitle:[item title] action:nil keyEquivalent:@""];
		} else {
			[m addItemWithTitle:@"clicked outside" action:nil keyEquivalent:@""];
		}
        return m;
	}
	return nil;
}

#pragma mark -
#pragma mark Source List Delegate Methods

- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id)group
{
	if([[group identifier] isEqualToString:@"log"] || [[group identifier] isEqualToString:@"traktable"])
		return YES;
	
	return NO;
}


- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
	NSIndexSet *selectedIndexes = [self.sourceList selectedRowIndexes];
	
	//Set the label text to represent the new selection
	if([selectedIndexes count]>1) {
	
        // multiple
	} else if([selectedIndexes count]==1) {

		NSString *identifier = [[self.sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];

		[self switchView:identifier];
        
    } else {
		// none
	}
}

- (void)sourceListDeleteKeyPressedOnRows:(NSNotification *)notification
{
	NSIndexSet *rows = [[notification userInfo] objectForKey:@"rows"];
	
	NSLog(@"Delete key pressed on rows %@", rows);
	
	//Do something here
}

- (BOOL)sourceList:(PXSourceList*)aSourceList shouldEditItem:(id)item {
    
    return NO;
}

- (IBAction)clearErrors:(id)sender {
    
    [self.errorViewController clearErrors:self];
}

- (IBAction)clearQueue:(id)sender {
    
    [self.queueViewController clearQueue:self];
}

- (void)updateProgress:(NSNotification *)aNotification;
{
    ITSync *sync = aNotification.object;
    
    [self.progressLabel setStringValue:[NSString stringWithFormat:@"total: %ld, done:", sync.totalItemsInQueue, sync.itemsDone]];
}

@end
