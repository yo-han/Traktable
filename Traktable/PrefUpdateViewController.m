//
//  PrefSyncViewController.m
//  Traktable
//
//  Created by Johan Kuijt on 27-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "PrefUpdateViewController.h"

@interface PrefUpdateViewController()

@end

@implementation PrefUpdateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    
    return self;
}

- (void) viewWillAppear {
    
}

-(NSString *)identifier{
    return @"Updates";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNameNetwork];
}

-(NSString *)toolbarItemLabel{
    return @"Updates";
}
@end