//
//  ITQueue.m
//  Traktable
//
//  Created by Johan Kuijt on 09-10-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITQueue.h"
#import "ITDb.h"
#import "ITUtil.h"
#import "ITTableGroupDateCellView.h"

@implementation ITQueue

+ (ITQueue *)queueEntityWithErrorObject:(id)object {
    
    if([object isKindOfClass:[ITDateGroupHeader class]]) {
        
        return object;
    }
    
    return nil;
}

- (NSArray *)fetchQueue {
    
    ITDb *db = [ITDb new];

    NSArray *results = [db executeAndGetResults:@"select * from traktQueue" arguments:nil];
   
    return results;
}

- (void)clearQueue {
    
    ITDb *db = [ITDb new];
    
    [db executeAndGetResults:@"delete from traktQueue" arguments:nil];
}

@end
