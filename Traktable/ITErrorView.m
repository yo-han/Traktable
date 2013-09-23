//
//  ITErrorView.m
//  Traktable
//
//  Created by Johan Kuijt on 21-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITErrorView.h"
#import "ITErrors.h"
#import "ITConstants.h"

@interface ITErrorView ()

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, assign) ITTableViewCellType tableViewCellType;
@property (nonatomic, assign, readwrite) ITSourceListIdentifier tableType;

@end

@implementation ITErrorView

- (id)init
{
    self = [super initWithNibName:@"ErrorViewController" bundle:nil];
    if (self != nil)
    {
    }
    return self;
}

- (IBAction)clearErrors:(id)sender {
    
    [[ITErrors new] clearErrors];
    
    [self reloadTableData];
}

- (void)refreshTableData:(ITSourceListIdentifier)tableType {
    
    _tableType = tableType;
    
    [self.items removeAllObjects];
    
    _tableViewCellType = ITTableViewErrorCell;
    _items = (NSMutableArray *) [[ITErrors new] fetchErrors];
    
    [self reloadTableView];
}

- (void)reloadTableData {
    
    [self refreshTableData:self.tableType];
}

- (void)reloadTableView {
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

@end
