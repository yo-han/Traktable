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

@property (nonatomic, weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, weak) IBOutlet NSSplitView *splitView;
@property (nonatomic, weak) IBOutlet NSView *placeholderView;
@property (nonatomic, weak) IBOutlet NSButton *bottomBarButton;
@property (nonatomic, weak) IBOutlet NSTextField *progressLabel;

- (IBAction)clearErrors:(id)sender;
- (IBAction)clearQueue:(id)sender;

@end
