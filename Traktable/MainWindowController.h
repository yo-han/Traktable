//
//  MainWindowController.h
//  Traktable
//
//  Created by Johan Kuijt on 28-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@interface MainWindowController : NSWindowController <PXSourceListDataSource, PXSourceListDelegate, NSSplitViewDelegate>

@property (nonatomic, strong) IBOutlet PXSourceList *sourceList;

@property (nonatomic, strong) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, strong) IBOutlet NSSplitView *splitView;
@property (nonatomic, strong) IBOutlet NSView *placeholderView;

@end
