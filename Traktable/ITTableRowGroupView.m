//
//  ITTableRowGroupView.m
//  Traktable
//
//  Created by Johan Kuijt on 03-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTableRowGroupView.h"

@implementation ITTableRowGroupView

static NSGradient *gradientWithTargetColor(NSColor *targetColor) {
    NSArray *colors = [NSArray arrayWithObjects:[targetColor colorWithAlphaComponent:0.5], targetColor, [targetColor colorWithAlphaComponent:0.5], nil];
    const CGFloat locations[4] = { 0.0, 1.0 };
    return [[NSGradient alloc] initWithColors:colors atLocations:locations colorSpace:[NSColorSpace sRGBColorSpace]];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    
    [self.backgroundColor set];
    
    NSRectFill(self.bounds);
    
    NSGradient *gradient = gradientWithTargetColor([NSColor colorWithDeviceWhite:0.7 alpha:0.1]);
    [gradient drawInRect:self.bounds angle:90];
    
    self.alphaValue = 0.9;
}

@end
