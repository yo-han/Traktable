//
//  ITErrors.m
//  Traktable
//
//  Created by Johan Kuijt on 02-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITErrors.h"
#import "ITDb.h"

@implementation ITErrors

- (NSArray *)fetchErrors {

    NSMutableArray *errors = [NSMutableArray array];
    ITDb *db = [ITDb new];
    
    NSArray *results = [db executeAndGetResults:@"select * from errors ORDER BY timestamp DESC" arguments:nil];
    
    for (NSDictionary *result in results) {

        [errors addObject:result];
    }
    
    return errors;
}

@end
