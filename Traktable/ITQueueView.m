//
//  ITQueueView.m
//  Traktable
//
//  Created by Johan Kuijt on 09-10-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITQueueView.h"
#import "ITQueue.h"
#import "ITConstants.h"
#import "ITTableGroupDateCellView.h"
#import "ITTableRowView.h"
#import "ITTableRowGroupView.h"

@interface ITQueueView ()

@property (nonatomic, assign) ITTableViewCellType tableViewCellType;
@property (nonatomic, assign, readwrite) ITSourceListIdentifier tableType;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ITQueueView

@synthesize tableView=_tableView;
@synthesize noItemsMention;

- (id)init
{
    self = [super initWithNibName:@"QueueViewController" bundle:nil];
    if (self != nil)
    {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.tableViewCellType = ITTableViewErrorCell;
    
    if(self.items == nil)
        self.items = [NSMutableArray array];
    
    [self reloadTableData];
}

- (void)reloadTableData {
    
    [self refreshTableData:self.tableType];
}

- (void)refreshTableData:(ITSourceListIdentifier)tableType {
    
    _tableType = tableType;
    
    [_items removeAllObjects];
    
    _tableViewCellType = ITTableViewErrorCell;
    _items = (NSMutableArray *) [[ITQueue new] fetchQueue];

    if([self.items count] > 0)
       [self.noItemsMention setHidden:NO];
    else
       [self.noItemsMention setHidden:YES];
    
    [self reloadTableView];
}

- (void)reloadTableView {
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (IBAction)clearQueue:(id)sender {
    
    [[ITQueue new] clearQueue];
    
    [self reloadTableData];
}

- (id)entryForRow:(NSInteger)row {
    
    if (row >= [self.items count])
        return nil;
    
    id entry = [ITQueue queueEntityWithErrorObject:[self.items objectAtIndex:row]];
    
    return entry;
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *cellType = [ITConstants tableViewCellTypes][@(self.tableViewCellType)];
    
    NSDictionary *entry = [self.items objectAtIndex:row];
    
    ITTableGroupDateCellView *cellView = [tableView makeViewWithIdentifier:cellType owner:self];
    
    if(row >= [self.items count])
        return nil;
    
    //[cellView.textField setStringValue:[entry objectForKey:@"description"]];
    
    return cellView;
}

#pragma mark -
#pragma mark NSTableViewDelegate & Datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    return [self.items count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    id entry = [self entryForRow:row];
    
    if([entry isKindOfClass:[ITDateGroupHeader class]])
        return 28.0;
    
    return 50.0;
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