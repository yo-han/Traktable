//
//  ITErrors.h
//  Traktable
//
//  Created by Johan Kuijt on 02-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITErrors : NSObject

+ (ITErrors *)errorEntityWithErrorObject:(id)object;

- (NSArray *)fetchErrors;
- (void)clearErrors;

@end