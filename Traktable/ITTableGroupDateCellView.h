//
//  ITTableGroupDateCellView.h
//  Traktable
//
//  Created by Johan Kuijt on 23-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITTableGroupDateCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField *timestamp;

@end

@interface ITDateGroupHeader : NSObject

@property (nonatomic, strong) NSString *date;

- (id)initWithDateString:(NSString *)date;

@end
