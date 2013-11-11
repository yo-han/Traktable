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
#import "ITQueueTableCellView.h"
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
    
    ITQueueTableCellView *cellView = [tableView makeViewWithIdentifier:cellType owner:self];
    
    if(row >= [self.items count])
        return nil;
    
    NSDictionary *p = [NSJSONSerialization JSONObjectWithData:[[entry objectForKey:@"params"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:p];
    
    NSString *title;
    
    if([params objectForKey:@"season"] != nil) {
        title = [NSString stringWithFormat:@"%@ %@", [params objectForKey:@"title"], [NSString stringWithFormat:@"S%02dE%02d", [[params objectForKey:@"season"] intValue], [[params objectForKey:@"episode"] intValue]]];
    } else {
        title = [NSString stringWithFormat:@"%@ (%@)", [params objectForKey:@"title"], [params objectForKey:@"year"]];
    }
    
    if(title != nil)
        [cellView.textField setStringValue:title];
    
    if([params objectForKey:@"media_center_date"] != nil)
        [cellView.timestamp setStringValue:[params objectForKey:@"media_center_date"]];
    
    [cellView.imageView setImage:[NSImage imageNamed:@"movies"]];
    
    return cellView;
}

#pragma mark -
#pragma mark NSTableViewDelegate & Datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if([self.items count] > 0)
        [self.noItemsMention setHidden:YES];
    else
        [self.noItemsMention setHidden:NO];
    
    return [self.items count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    return 50.0;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    
    return NO;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    
    if (row >= [self.items count])
        return nil;
    
    ITTableRowView *result = [[ITTableRowView alloc] init];
    result.objectValue = [self.items objectAtIndex:row];
    return result;
}

@end