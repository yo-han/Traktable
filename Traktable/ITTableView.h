//
//  ITTableView.h
//  Traktable
//
//  Created by Johan Kuijt on 29-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITConstants.h"

@interface ITTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, assign, readonly) ITSourceListIdentifier tableType;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;

- (void)setup;
- (void)reloadTableData;
- (void)refreshTableData:(ITSourceListIdentifier)tableType;

- (IBAction)clearErrors:(id)sender;

@end
