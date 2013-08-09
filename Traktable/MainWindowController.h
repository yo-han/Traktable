//
//  MainWindowController.h
//  Traktable
//
//  Created by Johan Kuijt on 28-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@class ITTableView;

@interface MainWindowController : NSWindowController <PXSourceListDataSource, PXSourceListDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet ITTableView *tableView;
@property (nonatomic, strong) IBOutlet PXSourceList *sourceList;

@end
