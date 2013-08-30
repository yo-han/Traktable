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

static NSGradient *gradientWithTargetColor(NSColor *targetColor) {
    NSArray *colors = [NSArray arrayWithObjects:[targetColor colorWithAlphaComponent:0], targetColor, [targetColor colorWithAlphaComponent:0], nil];
    const CGFloat locations[4] = { 0.0, 1.0 };
    return [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {

    [self.backgroundColor set];

    NSRectFill(self.bounds);
    
    NSGradient *gradient = gradientWithTargetColor([NSColor colorWithDeviceWhite:0.95 alpha:0.9]);
    [gradient drawInRect:self.bounds angle:90];

}

- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleLight;
}

@end
