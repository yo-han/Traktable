//
//  TMDBRequestDelegate.h
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMDBRequest;

@protocol TMDBRequestDelegate <NSObject>

@required

/**
 * Called when a TMDBRequest is finished and the data has been loaded, or an error occured.
 */
- (void)request:(TMDBRequest *)request didFinishLoading:(NSError *)error;

@end