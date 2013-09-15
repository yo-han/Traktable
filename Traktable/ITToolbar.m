//
//  ITToolbar.m
//  Traktable
//
//  Created by Johan Kuijt on 02-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITToolbar.h"

@implementation ITToolbar

// Automatically create accessor methods
@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
        [self setEndingColor:nil];
        [self setAngle:270];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    
    if (endingColor == nil || [startingColor isEqual:endingColor]) {
        
        [startingColor set];
        NSRectFill(rect);
    }
    else {
        // Fill view with a top-down gradient
        // from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc]
                                 initWithStartingColor:startingColor
                                 endingColor:endingColor];
        [aGradient drawInRect:[self bounds] angle:angle];
    }

    if([self bounds].size.height < 30) {
        
        NSGradient* aBorderGradient = [[NSGradient alloc]
                                 initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]
                                 endingColor:[NSColor colorWithCalibratedWhite:0.3 alpha:1.0]];
        
        NSRect bounds = [self bounds];
        NSRect borderBounds = NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, 1.5);
        
        NSBezierPath *bottomBorder = [NSBezierPath bezierPathWithRoundedRect:borderBounds xRadius:0 yRadius:0];
        [bottomBorder setLineWidth:5];
        [aBorderGradient drawInBezierPath:bottomBorder angle:angle];
    }
}

- (void)awakeFromNib {
    
    [self setStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
    [self setEndingColor:[NSColor colorWithCalibratedWhite:0.99 alpha:1.0]];
    [self setAngle:270];
}

@end
