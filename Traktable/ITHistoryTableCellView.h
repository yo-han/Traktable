//
//  ITHistoryTableCellView.h
//  Traktable
//
//  Created by Johan Kuijt on 21-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITHistoryTableCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField *title;
@property (nonatomic, strong) IBOutlet NSTextField *year;
@property (nonatomic, strong) IBOutlet NSTextField *scrobble;
@property (nonatomic, strong) IBOutlet NSTextField *timestamp;

@end
