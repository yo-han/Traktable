//
//  ITHistoryView.m
//  Traktable
//
//  Created by Johan Kuijt on 29-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITHistoryView.h"
#import "ITHistory.h"
#import "ITTableGroupDateCellView.h"
#import "ITTableRowGroupView.h"
#import "ITTableRowView.h"
#import "ITHistoryTableCellView.h"
#import "ITUtil.h"

@interface ITHistoryView()

@property (nonatomic, strong) ITHistory *history;

@property (nonatomic, assign) ITTableViewCellType tableViewCellType;
@property (nonatomic, assign, readwrite) ITSourceListIdentifier tableType;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ITHistoryView

@synthesize tableView=_tableView;

- (id)init
{
    self = [super initWithNibName:@"HistoryViewController" bundle:nil];
    if (self != nil)
    {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.tableViewCellType = ITTableViewMovieHistoryCell;
    
    if(self.items == nil)
        self.items = [NSMutableArray array];
    
    // Register an observer for history updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:kITHistoryNeedsUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:kITHistoryTableReloadNotification object:nil];    
}

- (ITHistory *)getHistory {

    if(self.history == nil)
        _history = [ITHistory new];
    
    return self.history;
}

- (void)reloadTableData {
    
    [self refreshTableData:self.tableType];
}

- (void)refreshTableData:(ITSourceListIdentifier)aTableType {
    
    self.tableType = aTableType;
    
    [self.items removeAllObjects];
    
    switch (self.tableType) {
        case ITHistoryTVShows:
            self.tableViewCellType = ITTableViewTVShowHistoryCell;
            self.items = (NSMutableArray *) [[self getHistory] fetchTvShowHistory];
            break;
        case ITHistoryMovies:
        default:
            self.tableViewCellType = ITTableViewMovieHistoryCell;
            self.items = (NSMutableArray *) [[self getHistory] fetchMovieHistory];
    }
   
    [self reloadTableView];
}

- (void)reloadTableView {
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (IBAction)historyMovies:(id)sender {
    
    [self.historyMoviesButton setState:1];
    [self.historyShowsButton setState:0];
    
    [self refreshTableData:ITHistoryMovies];
}

- (IBAction)historyShows:(id)sender {
    
    [self.historyMoviesButton setState:0];
    [self.historyShowsButton setState:1];
    
    [self refreshTableData:ITHistoryTVShows];
}

- (id)entryForRow:(NSInteger)row {
    
    if (row >= [self.items count])
        return nil;
    
    id entry = [ITHistory historyEntityWithHistoryObject:[self.items objectAtIndex:row]];

    return entry;
}

- (NSTableCellView *)viewForRow:(NSInteger)row type:(NSString *)cellType {
    
    if(self.tableViewCellType == ITTableViewMovieHistoryCell || self.tableViewCellType == ITTableViewTVShowHistoryCell) {
        
        id entry = [self entryForRow:row];
        
        if(entry == nil)
            return nil;
        
        if([entry isKindOfClass:[ITDateGroupHeader class]]) {
            
            ITTableGroupDateCellView *cellView = [self.tableView makeViewWithIdentifier:@"dateGroupCell" owner:self];
            
            ITDateGroupHeader *_entry = (ITDateGroupHeader *) entry;
            
            [cellView.timestamp setStringValue:_entry.date];
            
            return cellView;
        }
        
        ITHistoryTableCellView *cellView = [self.tableView makeViewWithIdentifier:cellType owner:self];
        
        ITHistory *_entry = (ITHistory *) entry;
        
        NSString *time = [ITUtil stringToTime:_entry.timestamp];
        
        [cellView.timestamp setStringValue:time];

        if(_entry.traktUrl)
            [cellView.traktUrl setTag:row];
        else
            [cellView.traktUrl setHidden:YES];
        
        if(_entry.poster != nil)
            [cellView.imageView setImage:_entry.poster];
        else
            [cellView.imageView setImage:[NSImage imageNamed:@"movies.png"]];
        
        if(self.tableViewCellType == ITTableViewMovieHistoryCell) {
            
            [cellView.title setStringValue:_entry.title];
            [cellView.year setStringValue:_entry.year];
            [cellView.scrobble setStringValue: NSLocalizedString(_entry.action, nil)];
            
        } else if (self.tableViewCellType == ITTableViewTVShowHistoryCell) {

            [cellView.title setStringValue:[NSString stringWithFormat:@"%@ - %@",_entry.title,_entry.episodeTitle]];
            [cellView.seasonLabel setBackgroundColor:[NSColor blackColor]];
            [cellView.seasonLabel setDrawsBackground:YES];
            [cellView.seasonLabel setBordered:NO];
            [cellView.episodeSeasonNumber setStringValue:[NSString stringWithFormat:@"S%02ldE%02ld", (long)_entry.season, (long)_entry.episode]];
            
            [cellView.scrobble setStringValue: NSLocalizedString(_entry.action, nil)];
            
        }
        
        return cellView;
        
    }
    
    return nil;
}

- (IBAction)openTraktUrl:(id)sender {
    
    NSButton *btn = (NSButton *) sender;
    
    ITHistory *entry = [self entryForRow:btn.tag];

    if(![entry isKindOfClass:[ITDateGroupHeader class]]) {
        
        NSString *url = entry.traktUrl;

        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark -
#pragma mark NSTableViewDelegate & Datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {

    return [self.items count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *cellType = [ITConstants tableViewCellTypes][@(self.tableViewCellType)];
    
    NSTableCellView *cellView = [self viewForRow:row type:cellType];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    id entry = [self entryForRow:row];
    
    if(self.tableViewCellType == ITTableViewErrorCell) {
        
        if([entry isKindOfClass:[ITDateGroupHeader class]])
            return 28.0;
        
        return 50.0;
        
    } else {
        
        if([entry isKindOfClass:[ITDateGroupHeader class]])
            return 28.0;
    }
    
    return 150.0;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    
    id entry = [self entryForRow:row];
    
    if([entry isKindOfClass:[ITDateGroupHeader class]]) {
        return YES;
    }
    
    return NO;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    
    if (row >= [self.items count])
        return nil;
    
    id entry = [self entryForRow:row];
    
    if([entry isKindOfClass:[ITDateGroupHeader class]])
        return [[ITTableRowGroupView alloc] init];
    
    ITTableRowView *result = [[ITTableRowView alloc] init];
    result.objectValue = [self.items objectAtIndex:row];
    return result;
}

@end
