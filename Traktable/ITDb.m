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
#import "ITSync.h"

static NSString *dbFile = @"iTraktor.db";
static int dbVersion = 2;

@interface ITDb()

@property (nonatomic, strong) NSString *dbFilePath;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic) int errorCode;
@property (nonatomic) int lastInsertId;
@property (nonatomic) BOOL hasError;

@end

@implementation ITDb

- (id)init {
    
    self = [super init];
    if (self) {
        
        _dbFilePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:dbFile];
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbFilePath];
    }
    
    return self;
}

- (NSString *)getDbFilePath {
    
    return self.dbFilePath;
}

- (NSString *)lastErrorMessage {
    
    return self.errorMessage;
}

- (int)lastErrorCode {
    
    return self.errorCode;
}

- (BOOL)error {
    
    return self.hasError;
}

- (NSNumber *)lastInsertRowId {
    
    return [NSNumber numberWithInt:self.lastInsertId];
}

- (NSString *)getInsertQueryFromDictionary:(NSDictionary *)dict queryType:(NSString *)type forTable:(NSString *)table {
    
    NSMutableArray *cols = [NSMutableArray array];
    NSMutableArray *bind = [NSMutableArray array];
    
    for (id key in dict) {
        
        [cols addObject:key];
        [bind addObject:[NSString stringWithFormat:@":%@",key]];
    }
    
    NSString *columnNames = [cols componentsJoinedByString:@","];
    NSString *bindValues = [bind componentsJoinedByString:@","];
    
    NSString *qry = [NSString stringWithFormat:@"%@ INTO %@ (%@) VALUES (%@)", type, table, columnNames, bindValues];
    
    return qry;
}

- (NSString *)getUpdateQueryFromDictionary:(NSDictionary *)dict forTable:(NSString *)table whereCol:(NSString *)where {
    
    NSMutableArray *cols = [NSMutableArray array];
    
    for (id key in dict) {
        
        NSString *col = [NSString stringWithFormat:@"%@ = :%@", key, key];
        [cols addObject:col];
    }
    
    NSString *columnNames = [cols componentsJoinedByString:@","];
    
    NSString *qry = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = :where", table, columnNames, where];

    
    return qry;
}

- (void)executeUpdateUsingQueue:(NSString *)sql arguments:(id)args {
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if([args isKindOfClass:[NSArray class]])
            [db executeUpdate:sql withArgumentsInArray:args];
        else if([args isKindOfClass:[NSDictionary class]])
            [db executeUpdate:sql withParameterDictionary:args];
        
        self.errorMessage = [db lastErrorMessage];
        self.lastInsertId = (int) [db lastInsertRowId];
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
        
        FMResultSet *s;
        
        if(args == nil) {

            s = [db executeQuery:sql];
            
        } else if([args isKindOfClass:[NSArray class]] && [args count] > 0) {

            s = [db executeQuery:sql withArgumentsInArray:args];
        } else {
            
            NSLog(@"Invalid query: %@ with arguments: %@", sql, args);
            return;
        }
        
        self.errorMessage = [db lastErrorMessage];
        
        while ([s next]) {
            
            [resultSet addObject:[s resultDictionary]];
        }
        
        [s close];
    }];
    
    return (NSArray *) resultSet;
}

- (int)databaseSchemaVersion {
    
    __block int version = 0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {

        FMResultSet *resultSet = [db executeQuery:@"PRAGMA user_version"];
        
        if ([resultSet next]) {
            version = [resultSet intForColumnIndex:0];
        }
        
        [resultSet close];
    }];
     
    return version;
}

- (void)setDatabaseSchemaVersion:(int)version {
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        sqlite3_exec(db.sqliteHandle, [[NSString stringWithFormat:@"PRAGMA user_version=%d", dbVersion] UTF8String], NULL, NULL, NULL);
    }];
}

- (BOOL)databaseNeedsMigration {
    return [self databaseSchemaVersion] < dbVersion;
}

- (void)migrateDatabase {
    
    int version = [self databaseSchemaVersion];
    
    if (version >= dbVersion)
        return;
    
    NSLog(@"Migrating database schema from version %d to version %d", version, dbVersion);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITMigrateProgressWindowNotification object:nil];
    
    [self backupDatabaseFile];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if (version < 1) {
            
            [db executeUpdate:@"CREATE TABLE \"movies\" (\"movieId\" INTEGER PRIMARY KEY AUTOINCREMENT,\"tmdb_id\" INTEGER,\"imdb_id\" INTEGER,\"extended\" INTEGER, \"year\" INTEGER,\"traktPlays\" INTEGER,\"released\" INTEGER,\"runtime\" INTEGER,\"poster\" TEXT,\"title\" TEXT,\"tagline\" TEXT,\"overview\" TEXT,\"trailer\" TEXT,\"traktUrl\" TEXT,\"genres\" BLOB);"];
            
            [db executeUpdate:@"CREATE UNIQUE INDEX \"uid_movie\" ON \"movies\" (\"tmdb_id\");"];            
            
            [db executeUpdate:@"CREATE TABLE \"tvshows\" (\"showId\" INTEGER PRIMARY KEY AUTOINCREMENT,\"tvdb_id\" INTEGER,\"tvrage_id\" INTEGER,\"imdb_id\" TEXT,\"extended\" INTEGER,\"year\" INTEGER,\"runtime\" INTEGER,\"seasons\" INTEGER,\"episodes\" INTEGER,\"firstAired\" INTEGER,\"title\" TEXT,\"status\" TEXT,\"traktUrl\" TEXT,\"overview\" TEXT,\"network\" TEXT,\"poster\" TEXT,\"genres\" TEXT,\"country\" TEXT,\"rating\" TEXT,\"airTime\" TEXT,\"airDay\" TEXT)"];
            
            [db executeUpdate:@"CREATE UNIQUE INDEX \"uid_show\" ON \"tvshows\" (\"tvdb_id\");"];
            
            [db executeUpdate:@"CREATE TABLE \"episodes\" (\"episodeId\" INTEGER PRIMARY KEY AUTOINCREMENT,\"showTvdb_id\" INTEGER,\"tvdb_id\" INTEGER,\"showImdb_id\" TEXT,\"season\" INTEGER,\"episode\" INTEGER,\"screenImage\" TEXT,\"overview\" TEXT,\"title\" TEXT,\"traktUrl\" TEXT);"];
            
            [db executeUpdate:@"CREATE UNIQUE INDEX \"uid_episode\" ON \"episodes\" (\"tvdb_id\");"];
            
            [db executeUpdate:@"CREATE TABLE \"history\" (\"uid\" TEXT PRIMARY KEY,\"tvdb_id\" INTEGER,\"tmdb_id\" INTEGER,\"imdb_id\" TEXT,\"type\" TEXT,\"action\" TEXT,\"timestamp\" DATETIME,\"season\" INTEGER,\"episode\" INTEGER);"];
            
            [db executeUpdate:@"CREATE TABLE \"errors\" (\"errorId\" INTEGER PRIMARY KEY AUTOINCREMENT,\"description\" TEXT,\"timestamp\" DATETIME);"];
            
        }
        
        if(version < 2) {
            
            [db executeUpdate:@"CREATE TABLE \"traktQueue\" (\"url\" TEXT,\"params\" TEXT);"];
        }
    }];
    
    [self setDatabaseSchemaVersion:dbVersion];

    [ITSync syncTraktExtendedInBackgroundThread];
    
    NSLog(@"Database schema version after migration is %d", [self databaseSchemaVersion]);
}

- (void)backupDatabaseFile {
    
    int version = [self databaseSchemaVersion];
    
    NSString *source = [self getDbFilePath];
    NSString *destination = [NSString stringWithFormat:@"%@.v%d", source, version];

    if ([[NSFileManager defaultManager] isReadableFileAtPath:source])
        [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:source] toURL:[NSURL fileURLWithPath:destination] error:nil];
}

@end
