//
//  ITQueueView.h
//  Traktable
//
//  Created by Johan Kuijt on 09-10-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITConstants.h"

@class ITToolbar;

@interface ITQueueView : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, assign, readonly) ITSourceListIdentifier tableType;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSTextField *noItemsMention;

- (void)refreshTableData:(ITSourceListIdentifier)aTableType;
- (void)reloadTableView;

- (IBAction)clearQueue:(id)sender;

@end
