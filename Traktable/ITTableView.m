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

@interface ITTableView()

typedef NS_ENUM(NSUInteger, ITTableViewCellType) {
    ITTableViewHistoryCell = 0,
    ITTableViewUnknownCell = NSUIntegerMax
};

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign) ITTableViewCellType tableViewCellType;
@property (nonatomic, assign, readwrite) ITSourceListIdentifier tableType;

@end

@implementation ITTableView

@synthesize tableView=_tableView;

- (void)refreshTableData:(ITSourceListIdentifier)tableType {

    if(self.items == nil)
        _items = [NSMutableArray array];
    
    NSMutableArray *a = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",nil];
    
    [self.items removeAllObjects];
    
    switch (tableType) {
        case ITHistoryMovies:
            _items = a;
            break;
            
        default:
            NSLog(@"1!");
            break;
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.items count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *cellType = [[self class] tableViewCellTypes][@(self.tableViewCellType)];
    ITHistoryTableCellView *cellView = [tableView makeViewWithIdentifier:cellType owner:self];
  
    [cellView.label setStringValue:@"123"];
    
    return cellView;
}

+ (NSDictionary *)tableViewCellTypes
{
    return @{@(ITTableViewHistoryCell) : @"HistoryCell",
             @(ITTableViewUnknownCell) : @"DefaultCell"};
}

@end
