//
//  MainWindowController.m
//  Traktable
//
//  Created by Johan Kuijt on 28-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "MainWindowController.h"
#import "SourceListItem.h"
#import "ITTableView.h"
#import "ITConstants.h"
#import "ITToolbar.h"

@interface MainWindowController ()

@property (nonatomic, strong) NSMutableArray *sourceListItems;

@end

@implementation MainWindowController

@synthesize toolbar=_toolbar;

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
}

- (void)awakeFromNib
{	
	_sourceListItems = [[NSMutableArray alloc] init];
	
	SourceListItem *historyItem = [SourceListItem itemWithTitle:NSLocalizedString(@"History", nil) identifier:@"history"];
	[historyItem setIcon:[NSImage imageNamed:@"menuicon.png"]];
	SourceListItem *moviesItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Movies", nil) identifier:@"movies"];
	[moviesItem setIcon:[NSImage imageNamed:@"movies.png"]];
    SourceListItem *tvShowsItem = [SourceListItem itemWithTitle:NSLocalizedString(@"TVShows", nil) identifier:@"tvshows"];
	[tvShowsItem setIcon:[NSImage imageNamed:@"movies.png"]];
    SourceListItem *logItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Log", nil) identifier:@"log"];
    [logItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
    SourceListItem *errorItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Errors", nil) identifier:@"errors"];
    [errorItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
	
    [historyItem setChildren:[NSArray arrayWithObjects:moviesItem, tvShowsItem, nil]];
    [logItem setChildren:[NSArray arrayWithObjects:errorItem, nil]];
	
	[self.sourceListItems addObject:historyItem];
    [self.sourceListItems addObject:logItem];
	
	[self.sourceList reloadData];
    
    [self.tableView setup];
    [self.tableView refreshTableData:ITHistoryMovies];
    
    [self.toolbar setHidden:YES];
    [self.tableViewBottomConstraint setConstant:0];
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
	if([[group identifier] isEqualToString:@"history"] || [[group identifier] isEqualToString:@"log"])
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
		
		NSDictionary *identifiers = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInteger:ITHistoryMovies],@"movies",
                                        [NSNumber numberWithInteger:ITHistoryTVShows],@"tvshows",
                                        [NSNumber numberWithInteger:ITErrorList],@"errors",
                                        nil];
        
        switch ([[identifiers objectForKey:identifier] intValue]) {
            case ITHistoryMovies: 
                [self.tableView refreshTableData:ITHistoryMovies];
                [self.tableViewBottomConstraint setConstant:0];
                [self.toolbar setHidden:YES];
                break;
            case ITHistoryTVShows:
                [self.tableView refreshTableData:ITHistoryTVShows];
                [self.tableViewBottomConstraint setConstant:0];
                [self.toolbar setHidden:YES];
                break;
            case ITErrorList:
                [self.tableView refreshTableData:ITErrorList];
                [self.tableViewBottomConstraint setConstant:41.0];
                [self.toolbar setHidden:NO];
                break;
            default:
                [self.tableViewBottomConstraint setConstant:0];
                [self.toolbar setHidden:YES];
        }
        
        
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

@end
