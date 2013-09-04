//
//  ITTableView.m
//  Traktable
//
//  Created by Johan Kuijt on 29-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTableView.h"
#import "ITHistory.h"
#import "ITHistoryTableCellView.h"
#import "ITErrorTableCellView.h"
#import "ITTableRowView.h"
#import "ITTableRowGroupView.h"
#import "ITTVShowPoster.h"
#import "ITUtil.h"
#import "ITErrors.h"

@interface ITTableView()

typedef NS_ENUM(NSUInteger, ITTableViewCellType) {
    ITTableViewMovieHistoryCell = 0,
    ITTableViewTVShowHistoryCell = 1,
    ITTableViewErrorCell = 2,
    ITTableViewUnknownCell = NSUIntegerMax
};

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) ITHistory *history;

@property (nonatomic, assign) ITTableViewCellType tableViewCellType;
@property (nonatomic, assign, readwrite) ITSourceListIdentifier tableType;

@end

@implementation ITTableView

@synthesize tableView=_tableView;

- (void)setup {
    
    _tableViewCellType = ITTableViewMovieHistoryCell;
    
    if(self.items == nil)
        _items = [NSMutableArray array];

    // Register an observer for history updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:kITHistoryNeedsUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:kITHistoryTableReloadNotification object:nil];
    
}

- (ITHistory *)getHistory {

    if(self.history == nil)
        _history = [ITHistory new];
    
    return self.history;
}

- (void)refreshTableData:(ITSourceListIdentifier)tableType {
    
    _tableType = tableType;
    
    [self.items removeAllObjects];
    
    switch (self.tableType) {
        case ITHistoryMovies:
            _tableViewCellType = ITTableViewMovieHistoryCell;
            _items = (NSMutableArray *) [[self getHistory] fetchMovieHistory];
            break;
        case ITHistoryTVShows:
            _tableViewCellType = ITTableViewTVShowHistoryCell;
            _items = (NSMutableArray *) [[self getHistory] fetchTvShowHistory];
            break;
        case ITErrorList:
            _tableViewCellType = ITTableViewErrorCell;
            _items = (NSMutableArray *) [[ITErrors new] fetchErrors];
            break;
        default:
            return;
    }

    [self reloadTableView];
}

- (void)reloadTableData {

    [self refreshTableData:self.tableType];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (IBAction)clearErrors:(id)sender {
    
    [[ITErrors new] clearErrors];
    
    [self reloadTableData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.items count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *cellType = [[self class] tableViewCellTypes][@(self.tableViewCellType)];
    
    if(self.tableViewCellType == ITTableViewMovieHistoryCell || self.tableType == ITTableViewTVShowHistoryCell) {
        
        id entry = [self _entryForRow:row];
        
        if([entry isKindOfClass:[ITHistoryGroupHeader class]]) {
            
            ITHistoryTableGroupCellView *cellView = [tableView makeViewWithIdentifier:@"historyGroupCell" owner:self];
            
            ITHistoryGroupHeader *_entry = (ITHistoryGroupHeader *) entry;
            
            [cellView.timestamp setStringValue:_entry.date];
            
            return cellView;
        }
        
        ITHistoryTableCellView *cellView = [tableView makeViewWithIdentifier:cellType owner:self];
        
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
                            
        } else if (self.tableType == ITTableViewTVShowHistoryCell) {
            
            [cellView.title setStringValue:[NSString stringWithFormat:@"%@ - %@",_entry.title,_entry.episodeTitle]];
            [cellView.seasonLabel setBackgroundColor:[NSColor blackColor]];
            [cellView.seasonLabel setDrawsBackground:YES];        
            [cellView.seasonLabel setBordered:NO];
            [cellView.episodeSeasonNumber setStringValue:[NSString stringWithFormat:@"S%02ldE%02ld", (long)_entry.season, (long)_entry.episode]];
            
            [cellView.scrobble setStringValue: NSLocalizedString(_entry.action, nil)];
            
        }
        
        return cellView;
    
    } else if(self.tableType == ITTableViewErrorCell) {
        
        ITErrorTableCellView *cellView = [tableView makeViewWithIdentifier:cellType owner:self];

        NSDictionary *entry = [self.items objectAtIndex:row];
        
        NSString *date = [ITUtil localeDateString:[entry objectForKey:@"timestamp"]];
        
        [cellView.timestamp setStringValue:date];
        [cellView.textField setStringValue:[entry objectForKey:@"description"]];
        
        return cellView;
    }
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    if(self.tableViewCellType == ITTableViewErrorCell) {
        
        return 50.0;
        
    } else {
        
        id entry = [self _entryForRow:row];
        
        if([entry isKindOfClass:[ITHistoryGroupHeader class]])
            return 28.0;
    }

    return 150.0;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    
    id entry = [self _entryForRow:row];
    
    if([entry isKindOfClass:[ITHistoryGroupHeader class]]) {
        return YES;
    }

    return NO;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    
    id entry = [self _entryForRow:row];
    
    if([entry isKindOfClass:[ITHistoryGroupHeader class]])
        return [[ITTableRowGroupView alloc] init];
    
    ITTableRowView *result = [[ITTableRowView alloc] init];
    result.objectValue = [self.items objectAtIndex:row];
    return result;
}

- (id)_entryForRow:(NSInteger)row {
    
    id entry = [ITHistory historyEntityWithHistoryObject:[self.items objectAtIndex:row]];

    return entry;
}

- (IBAction)openTraktUrl:(id)sender {
    
    NSButton *btn = (NSButton *) sender;
    ITHistory *entry = [self _entryForRow:btn.tag];
    
    NSString *url = entry.traktUrl;

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

+ (NSDictionary *)tableViewCellTypes
{
    return @{@(ITTableViewMovieHistoryCell) : @"MovieHistoryCell",
             @(ITTableViewTVShowHistoryCell) : @"TVShowHistoryCell",
             @(ITTableViewErrorCell) : @"ErrorCell",
             @(ITTableViewUnknownCell) : @"DefaultCell"};
}

@end
