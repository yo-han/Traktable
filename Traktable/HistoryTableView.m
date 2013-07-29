//
//  HistoryTableView.m
//  Traktable
//
//  Created by Johan Kuijt on 29-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "HistoryTableView.h"

@implementation HistoryTableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 2;
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
  
    return cellView;
}

@end
