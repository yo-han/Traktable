//
//  ITDb.m
//  Traktable
//
//  Created by Johan Kuijt on 06-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITDb.h"
#import "ITConstants.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

static NSString *dbFile = @"iTraktor.db";

@interface ITDb()

@property (nonatomic, strong) NSString *dbFilePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic) int lastInsertId;

@end

@implementation ITDb

- (id)init {
    
    _dbFilePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:dbFile];
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbFilePath];
    
    return self;
}

- (NSString *)getDbFilePath {
    
    return self.dbFilePath;
}

- (NSString *)lastErrorMessage {
    
    return self.errorMessage;
}

- (NSNumber *)lastInsertRowId {
    
    return [NSNumber numberWithInt:self.lastInsertId];
}

- (void)executeUpdateUsingQueue:(NSString *)sql arguments:(id)args {
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if([args isKindOfClass:[NSArray class]])
            [db executeUpdate:sql withArgumentsInArray:args];
        else if([args isKindOfClass:[NSDictionary class]])
            [db executeUpdate:sql withParameterDictionary:args];
        
        self.errorMessage = [db lastErrorMessage];
        self.lastInsertId = [db lastInsertRowId];
    }];
}

- (NSDictionary *)executeAndGetOneResult:(NSString *)sql arguments:(NSArray *)args {
    
    NSArray *results = [self executeAndGetResults:sql arguments:args];
    
    if([results count] > 0) {
        
        NSDictionary *dict = [results objectAtIndex:0];
        
        return dict;
    }
    
    return nil;
}

- (NSArray *)executeAndGetResults:(NSString *)sql arguments:(NSArray *)args {
    
    NSMutableArray *resultSet = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *s = [db executeQuery:sql withArgumentsInArray:args];
        
        self.errorMessage = [db lastErrorMessage];
        
        while ([s next]) {
            
            [resultSet addObject:[s resultDictionary]];
        }
        
        [s close];
    }];
    
    return (NSArray *) resultSet;
}


@end
