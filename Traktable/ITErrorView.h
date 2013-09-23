//
//  ITErrorView.h
//  Traktable
//
//  Created by Johan Kuijt on 21-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITConstants.h"

@class ITToolbar;

@interface ITErrorView : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, assign, readonly) ITSourceListIdentifier tableType;

@property (nonatomic, strong) IBOutlet NSTableView *tableView;

- (IBAction)clearErrors:(id)sender;

@end
