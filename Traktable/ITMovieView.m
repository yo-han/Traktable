//
//  ITMovieView.m
//  Traktable
//
//  Created by Johan Kuijt on 25-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITMovieView.h"

static const NSSize buttonSize = { 80, 20 };
static const NSSize itemSize = { 200, 300 };
static const NSPoint buttonOrigin = { 10, 10 };

@interface BVView : NSView
@property (weak) NSButton *button;
@end

@implementation BVView
@synthesize button;
- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:(NSRect){frameRect.origin, itemSize}];
    if (self) {
        NSButton *newButton = [[NSButton alloc]
                               initWithFrame:(NSRect){buttonOrigin, buttonSize}];
        [self addSubview:newButton];
        self.button = newButton;
    }
    return self;
}
@end


@interface BVPrototype : NSCollectionViewItem
@end

@implementation BVPrototype
- (void)loadView {
    [self setView:[[BVView alloc] initWithFrame:NSZeroRect]];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [[(BVView *)[self view] button] setTitle:representedObject];
}
@end

@interface ITMovieView ()

@property (strong) NSArray *titles;

@end

@implementation ITMovieView

@synthesize titles;

- (id)init
{
    self = [super initWithNibName:@"MovieViewController" bundle:nil];
    if (self != nil)
    {
        [self reload];
    }
    return self;
}

- (void)reload {

    self.titles = [NSArray arrayWithObjects:@"Case", @"Molly", @"Armitage",
                   @"Hideo", @"The Finn", @"Maelcum", @"Wintermute", @"Neuromancer", nil];
    
    NSCollectionView *cv = [[NSCollectionView alloc]
                            initWithFrame:[[self view] frame]];
    [cv setItemPrototype:[BVPrototype new]];
    [cv setContent:[self titles]];
    
    [cv setAutoresizingMask:(NSViewMinXMargin
                             | NSViewWidthSizable
                             | NSViewMaxXMargin
                             | NSViewMinYMargin
                             | NSViewHeightSizable
                             | NSViewMaxYMargin)];
    [[self view] addSubview:cv];
    [self.view needsLayout];
}

@end
