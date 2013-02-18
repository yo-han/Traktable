//
//  PrefIndexViewController.h
//  iTraktor
//
//  Created by Johan Kuijt on 12-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASPreferencesViewController.h"
#import "ITApi.h"

@interface PrefIndexViewController : NSViewController <MASPreferencesViewController, NSTextFieldDelegate>

@property(nonatomic, retain) IBOutlet NSTextField *name;
@property(nonatomic, retain) IBOutlet NSSecureTextField *password;
@property(nonatomic, retain) IBOutlet NSTextField *statusLabel;
@property(nonatomic, retain) IBOutlet NSButton *testButton;

@property(nonatomic, retain) ITApi *api;

@end
