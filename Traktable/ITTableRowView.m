//
//  ITTableRowView.m
//  Traktable
//
//  Created by Johan Kuijt on 23-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTableRowView.h"

@implementation ITTableRowView

@synthesize objectValue = _objectValue;

- (void)dealloc {
    self.objectValue = nil;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
    
        NSRect selectionRect = NSInsetRect(self.bounds, 2.0, 2.0);
        [[NSColor colorWithCalibratedWhite:.65 alpha:1.0] setStroke];
        [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:6 yRadius:6];
        [selectionPath fill];
        [selectionPath stroke];
        
    }
}

- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleLight;
}

@end
