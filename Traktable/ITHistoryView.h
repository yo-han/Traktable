//
//  ITTableView.h
//  Traktable
//
//  Created by Johan Kuijt on 29-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITConstants.h"

@class ITToolbar;

@interface ITHistoryView : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSButton *historyMoviesButton;
@property (nonatomic, strong) IBOutlet NSButton *historyShowsButton;

- (void)setup;

- (IBAction)historyMovies:(id)sender;
- (IBAction)historyShows:(id)sender;

- (void)refreshTableData:(ITSourceListIdentifier)aTableType;
- (void)reloadTableView;

@end
