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
#import "ITTableRowView.h"

@interface ITTableView()

typedef NS_ENUM(NSUInteger, ITTableViewCellType) {
    ITTableViewMovieHistoryCell = 0,
    ITTableViewTVShowHistoryCell = 1,
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
            
        default:
            _tableViewCellType = ITTableViewTVShowHistoryCell;
            _items = (NSMutableArray *) [[self getHistory] fetchTvShowHistory];
            break;
    }
 
    [self.tableView reloadData];
}

- (void)reloadTableData {

    [self refreshTableData:self.tableType];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.items count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *cellType = [[self class] tableViewCellTypes][@(self.tableViewCellType)];
    ITHistoryTableCellView *cellView = [tableView makeViewWithIdentifier:cellType owner:self];
    
    ITHistory *entry = [self _entryForRow:row];
   
    [cellView.title setStringValue:entry.title];
    [cellView.scrobble setStringValue:entry.success];
    [cellView.timestamp setStringValue:entry.timestamp];
    [cellView.imageView setImage:entry.poster];
    
    return cellView;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {

    ITTableRowView *result = [[ITTableRowView alloc] init];
    result.objectValue = [self.items objectAtIndex:row];
    return result;
}

- (ITHistory *)_entryForRow:(NSInteger)row {
    
    ITHistory *entry = [ITHistory historyEntityWithHistoryObject:[self.items objectAtIndex:row]];

    return entry;
}

+ (NSDictionary *)tableViewCellTypes
{
    return @{@(ITTableViewMovieHistoryCell) : @"MovieHistoryCell",
             @(ITTableViewTVShowHistoryCell) : @"TVShowHistoryCell",
             @(ITTableViewUnknownCell) : @"DefaultCell"};
}

@end
