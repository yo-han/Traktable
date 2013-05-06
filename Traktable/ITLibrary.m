//
//  ITLibrary.m
//  Traktable
//
//  Created by Johan Kuijt on 05-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITLibrary.h"
#import "ITApi.h"
#import "ITVideo.h"
#import "AppDelegate.h"

@interface ITLibrary()

- (id)init;
- (NSArray *)checkTracks:(NSArray *)tracks;
- (void)createDir:(NSString *)dir;

@end

@implementation ITLibrary

@synthesize iTunesBridge;
@synthesize dbQueue=_dbQueue;
@synthesize dbFilePath;
@synthesize firstImport;

- (id)init {
    
    iTunesBridge = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    ITApi *api = [ITApi new];
    
    NSString *appSupportPath = [ITLibrary applicationSupportFolder];
    [self createDir:appSupportPath];
    
    dbFilePath = [appSupportPath stringByAppendingPathComponent:@"iTraktor.db"];
    
    bool b = [self dbExists];
    
    if([api testAccount] && b == NO) {
        
        NSError *err;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *defaultDbPath = [NSString stringWithFormat:@"%@/iTraktor.db",[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/"]];
        
        [fileManager copyItemAtPath:defaultDbPath toPath:dbFilePath error:&err];
        
        NSLog(@"DB Create error: %@",err);
    }
    
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbFilePath];
    
    return self;
}

- (BOOL)dbExists {
    
    bool b = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
    
    return b;
}

- (SBElementArray *)getVideos:(iTunesESpK)playlist noCheck:(BOOL)noChecking {
    
    NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ITLastSyncDate"];
    NSString *predicateString;
    
    if(lastSyncDate == nil || noChecking == YES)
        predicateString = @"playedCount >= 0";
    else
        predicateString = @"(playedDate >= %@) AND (playedCount >= 0)";
    
    NSPredicate *trackFilter = [NSPredicate predicateWithFormat:predicateString, lastSyncDate];
    NSArray *tracks = [self getTrackList:trackFilter playlistType:playlist];

    return (SBElementArray *) tracks;
}

- (NSArray *)getTrackList:(NSPredicate *)filter playlistType:(iTunesESpK)playlist {
    
    iTunesSource *library = [[[[iTunesBridge sources] get] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kind == %i", iTunesESrcLibrary]] objectAtIndex:0];
    iTunesLibraryPlaylist *libraryPlaylist = [[[[library playlists] get] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"specialKind == %i", playlist]] objectAtIndex:0];
    
    NSArray *tracks = (NSMutableArray *) [(SBElementArray *)[[libraryPlaylist tracks] filteredArrayUsingPredicate:filter] get];
    
    return tracks;
}

- (iTunesTrack *)getTrack:(NSString *)persistentID type:(iTunesESpK)videoType {
    
    SBElementArray *library = [self getVideos:videoType noCheck:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentID == %@", persistentID];
    [library filterUsingPredicate:predicate];
    
    return [library objectAtIndex:0];
}

- (void)importLibrary {
    
    ITApi *api = [[ITApi alloc] init];
    firstImport = YES;
    
    NSArray *movies = [self getVideos:iTunesESpKMovies noCheck:YES];
    NSArray *shows = [self getVideos:iTunesESpKTVShows noCheck:YES];
    NSLog(@"%@", movies);
    NSArray *seenMovies = [self checkTracks:movies];
    if([seenMovies count] > 0)
        [api seen:seenMovies type:iTunesEVdKMovie video:nil];
    
    [self checkTracks:shows];
}

- (void)syncLibrary {

    if(![self dbExists]) {
        [self init];
        return;
    }
       
    ITApi *api = [[ITApi alloc] init];
    
    NSArray *movies = [self getVideos:iTunesESpKMovies noCheck:NO];
    NSArray *shows = [self getVideos:iTunesESpKTVShows noCheck:NO];
    firstImport = NO;

    NSArray *seenMovies = [self checkTracks:movies];
    if([seenMovies count] > 0)
        [api seen:seenMovies type:iTunesEVdKMovie video:nil];
    
    [self checkTracks:shows];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ITLastSyncDate"];
}

- (NSArray *)checkTracks:(NSArray *)tracks {
    
    NSMutableArray *seenVideos = [[NSMutableArray alloc] init];
    ITVideo *video = [ITVideo new];
    ITApi *api = [ITApi new];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue setMaxConcurrentOperationCount:1];    
    
    int i;
    for(i = 0; i < [tracks count]; i++) {
        
        NSBlockOperation *operation = [[NSBlockOperation alloc] init];

        [operation addExecutionBlock:
         ^{       
            iTunesTrack *track = [tracks objectAtIndex:i];
            __block id playedCount;

            [self.dbQueue inDatabase:^(FMDatabase *db) {
                FMResultSet *s = [db executeQuery:@"SELECT playedCount FROM library WHERE persistentId = ?", [[track persistentID] description]];
                
                if ([s next]) {
                    playedCount = [s objectForColumnName:@"playedCount"];
                }
                
                [s close];
            }];          
            
            if(playedCount == nil) {
      
                [self updateTrackCount:track scrobbled:NO];

                NSDictionary *videoDict;
                id scrobbleVideo;
                
                if([track seasonNumber] == 0) {
                    
                    videoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [track name], @"title",
                                 [NSNumber numberWithInteger:[track year]],@"year",
                                 [NSNumber numberWithInteger:[track playedCount]],@"plays",
                                 [NSNumber numberWithInteger:[[track playedDate] timeIntervalSince1970]],@"last_played",
                                 nil];
                    
                } else {
                    
                    videoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInteger:[track seasonNumber]],@"season",
                                 [NSNumber numberWithInteger:[track episodeNumber]],@"episode",
                                 nil];
                    
                    scrobbleVideo = [video getVideoByType:track type:iTunesEVdKTVShow];
                }

                if([track playedCount] > 0) {
                    
                    if([track seasonNumber] == 0) {
                        
                        [seenVideos addObject:videoDict];
                        
                    } else {
                        
                        if(firstImport)
                            [api seen:[NSArray arrayWithObject:videoDict] type:iTunesEVdKTVShow video:scrobbleVideo];
                        else
                            [api updateState:scrobbleVideo state:@"scrobble"];
                    }                        
                }
              
                if([api collection])
                    [api library:[NSArray arrayWithObject:videoDict] type:iTunesEVdKTVShow video:scrobbleVideo];
                
            } else if([playedCount integerValue] < [track playedCount]) {
                
                iTunesEVdK *type;
                
                if([track seasonNumber] == 0)
                    type = iTunesEVdKMovie;
                else
                    type = iTunesEVdKTVShow;
                
                id scrobbleVideo = [video getVideoByType:track type:type];
                [api updateState:scrobbleVideo state:@"scrobble"];
                
                [self updateTrackCount:track scrobbled:YES];
            }
         }];
         
        [queue addOperation: operation];
    }
    
    [queue waitUntilAllOperationsAreFinished];
    
    return seenVideos;
}

- (void)updateTrackCount:(iTunesTrack *)track scrobbled:(BOOL)scrobble {
    
    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[[track persistentID] description], @"id", [NSNumber numberWithInt:(int) [track playedCount]], @"played", [NSNumber numberWithBool:scrobble], @"scrobble", nil];
    
    NSLog(@"id: %@, played: %@", [argsDict objectForKey:@"id"], [argsDict objectForKey:@"played"]);
        
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"REPLACE INTO library (persistentId, playedCount, scrobbled) VALUES (:id, :played, :scrobble)" withParameterDictionary:argsDict];
    }];
}

- (void)createDir:(NSString *)dir {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if(![fileManager fileExistsAtPath:dir])
        if(![fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", dir);
}

+ (NSString *)applicationSupportFolder {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:
                                                0] : NSTemporaryDirectory();
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return [basePath
            stringByAppendingPathComponent:appName];
}

@end
