//
//  ITQueue.h
//  Traktable
//
//  Created by Johan Kuijt on 09-10-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITQueue : NSObject

+ (ITQueue *)queueEntityWithErrorObject:(id)object;

- (NSArray *)fetchQueue;
- (void)clearQueue;

@end
