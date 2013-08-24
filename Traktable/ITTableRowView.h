//
//  ITTableRowView.h
//  Traktable
//
//  Created by Johan Kuijt on 23-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITTableRowView : NSTableRowView {

    @private id _objectValue;
}

@property(retain) id objectValue;

@end
