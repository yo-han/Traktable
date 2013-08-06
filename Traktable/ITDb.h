//
//  ITDb.h
//  Traktable
//
//  Created by Johan Kuijt on 06-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

@interface ITDb : NSObject

- (NSString *)getDbFilePath;
- (NSString *)lastErrorMessage;

- (void)executeUpdateUsingQueue:(NSString *)sql arguments:(id)args;

- (NSDictionary *)executeAndGetOneResult:(NSString *)sql arguments:(NSArray *)args;
- (NSArray *)executeAndGetResults:(NSString *)sql arguments:(NSArray *)args;

@end
