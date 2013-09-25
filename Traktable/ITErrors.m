//
//  ITErrors.m
//  Traktable
//
//  Created by Johan Kuijt on 02-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITErrors.h"
#import "ITDb.h"
#import "ITUtil.h"
#import "ITTableGroupDateCellView.h"

@implementation ITErrors

+ (ITErrors *)errorEntityWithErrorObject:(id)object {
    
    if([object isKindOfClass:[ITDateGroupHeader class]]) {
        
        return object;
    }
    
    return nil;
}

- (NSArray *)fetchErrors {

    NSMutableArray *errors = [NSMutableArray array];
    ITDb *db = [ITDb new];
    
    NSString *lastGroup = nil;
    
    NSArray *results = [db executeAndGetResults:@"select * from errors ORDER BY timestamp DESC" arguments:nil];
    
    for (NSDictionary *result in results) {
        
        NSString *date = [ITUtil localeDateString:[result objectForKey:@"timestamp"]];
        
        if(![lastGroup isEqualToString:date]) {
            ITDateGroupHeader *header = [[ITDateGroupHeader alloc] initWithDateString:date];
            [errors addObject:header];
        }
        
        [errors addObject:result];
        
        lastGroup = date;        
    }
    
    return errors;
}

- (void)clearErrors {
    
    ITDb *db = [ITDb new];
    
    [db executeAndGetResults:@"delete from errors" arguments:nil];
    [db executeAndGetResults:@"delete from sqlite_sequence where name='errors'" arguments:nil];
    
}

@end
