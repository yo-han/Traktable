//
//  WebViewController.h
//  Traktable
//
//  Created by Johan Kuijt on 04-02-15.
//  Copyright (c) 2015 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebViewController : NSWindowController {
    
    WebView *myWebView;
}

@property (retain, nonatomic) IBOutlet WebView *myWebView;

@end
