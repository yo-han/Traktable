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
	
    SourceListItem *traktable = [SourceListItem itemWithTitle:NSLocalizedString(@"Traktable", nil) identifier:@"traktable"];
	[traktable setIcon:[NSImage imageNamed:@"movies.png"]];
    
	SourceListItem *historyItem = [SourceListItem itemWithTitle:NSLocalizedString(@"History", nil) identifier:@"history"];
	[historyItem setIcon:[NSImage imageNamed:@"movies.png"]];
	
    SourceListItem *logItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Log", nil) identifier:@"log"];
    [logItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
    SourceListItem *errorItem = [SourceListItem itemWithTitle:NSLocalizedString(@"Errors", nil) identifier:@"errors"];
    [errorItem setIcon:[NSImage imageNamed:NSImageNameIconViewTemplate]];
	
    [traktable setChildren:[NSArray arrayWithObjects:historyItem, nil]];
    [logItem setChildren:[NSArray arrayWithObjects:errorItem, nil]];
	
	[self.sourceListItems addObject:traktable];
    [self.sourceListItems addObject:logItem];
	
	[self.sourceList reloadData];
    
    [self.tableView setup];
    [self.tableView refreshTableData:ITHistoryMovies];
    
    [self.errorToolbar setHidden:YES];
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
		
		NSDictionary *identifiers = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInteger:ITHistoryMovies],@"history",
                                        [NSNumber numberWithInteger:ITErrorList],@"errors",
                                        nil];
        
        switch ([[identifiers objectForKey:identifier] intValue]) {
            case ITHistoryMovies: 
                [self.tableView refreshTableData:ITHistoryMovies];
                [self.tableViewBottomConstraint setConstant:0];
                [self.tableViewTopConstraint setConstant:28.0];
                [self.errorToolbar setHidden:YES];
                [self.historyToolbar setHidden:NO];
                break;
            case ITErrorList:
                [self.tableView refreshTableData:ITErrorList];
                [self.tableViewBottomConstraint setConstant:41.0];
                [self.tableViewTopConstraint setConstant:0];
                [self.errorToolbar setHidden:NO];
                [self.historyToolbar setHidden:YES];
                break;
            default:
                [self.tableViewBottomConstraint setConstant:0];
                [self.tableViewTopConstraint setConstant:28.0];
                [self.errorToolbar setHidden:YES];
                [self.historyToolbar setHidden:NO];
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

- (BOOL)sourceList:(PXSourceList*)aSourceList shouldEditItem:(id)item {
    
    return NO;
}

@end
