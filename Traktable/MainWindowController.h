//
//  MainWindowController.h
//  Traktable
//
//  Created by Johan Kuijt on 28-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@interface MainWindowController : NSWindowController <PXSourceListDataSource, PXSourceListDelegate, NSTableViewDataSource, NSTableViewDelegate> {

    IBOutlet PXSourceList *sourceList;
    IBOutlet NSTextField *selectedItemLabel;

    NSMutableArray *sourceListItems;
}

@end
