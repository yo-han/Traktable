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
#import "ITMovie.h"
#import "AppDelegate.h"
#import "ITConstants.h"
#import "ITDb.h"
#import "ITUtil.h"

@interface ITLibrary()

- (id)init;
- (void)checkTracks:(NSArray *)tracks;

@property dispatch_queue_t queue;
@property dispatch_group_t dispatchGroup;

@end

@implementation ITLibrary

@synthesize iTunesBridge;
@synthesize dbFilePath;
@synthesize firstImport;

- (id)init {
    
    self = [super init];
	if (self) {
        
        iTunesBridge = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        
        NSString *appSupportPath = [ITConstants applicationSupportFolder];
        [ITUtil createDir:appSupportPath];
        
        dbFilePath = [appSupportPath stringByAppendingPathComponent:@"iTraktor.db"];
        
        bool b = [self dbExists];
        
        if(b == NO) {
            
            [self resetDb];
        }
        
        _queue = dispatch_queue_create("traktable.library.queue", NULL);
        _dispatchGroup = dispatch_group_create();
        
        ITDb *db = [ITDb new];
        [db executeAndGetOneResult:@"SELECT playedCount FROM library" arguments:nil];

        if([db error]) {
            
            NSLog(@"Reset db is caused by error: %@", [db lastErrorMessage]);
            
            [[NSFileManager defaultManager] removeItemAtPath:dbFilePath error:nil];
            [self resetDb];
            
        } else if([db databaseNeedsMigration]) {
            
            [db migrateDatabase];
        }
    }
    
    return self;
}

- (BOOL)dbExists {
    
    bool b = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
      
    return b;
}

- (void)resetDb {
        
    NSError *err;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *defaultDbPath = [NSString stringWithFormat:@"%@/iTraktor.db",[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/"]];
    
    [fileManager copyItemAtPath:defaultDbPath toPath:dbFilePath error:&err];
    
    NSLog(@"DB Create error: %@",err);
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
    
    firstImport = YES;
    
    NSArray *movies = [self getVideos:iTunesESpKMovies noCheck:YES];
    NSArray *shows = [self getVideos:iTunesESpKTVShows noCheck:YES];

    [self checkTracks:movies];
    [self checkTracks:shows];
    
    dispatch_sync(self.queue, ^{
        printf("Import done.");
    });
}

- (void)syncLibrary {
   
    if(![self dbExists]) {
        [self resetDb];
    }
    
    NSArray *movies = [self getVideos:iTunesESpKMovies noCheck:NO];
    NSArray *shows = [self getVideos:iTunesESpKTVShows noCheck:NO];
    
    firstImport = NO;

    [self checkTracks:movies];
    [self checkTracks:shows];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ITLastSyncDate"];
}

- (void)checkTracks:(NSArray *)tracks {
    
    __block NSMutableArray *movies = [NSMutableArray array];
    __block NSMutableArray *shows = [NSMutableArray array];
    __block NSMutableDictionary *videos = [NSMutableDictionary dictionaryWithObjectsAndKeys:movies, @"movies", shows, @"shows", nil];

    ITApi *api = [ITApi new];

    int i;
    for(i = 0; i < [tracks count]; i++) {
        
        __block id playedCount;
        
        dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
        dispatch_group_async(self.dispatchGroup, self.queue, ^{
            
            iTunesTrack *track = [tracks objectAtIndex:i];
        
            sleep(2);
            
            ITDb *db = [ITDb new];
            
            NSDictionary *result = [db executeAndGetOneResult:@"SELECT playedCount FROM library WHERE persistentId = ?" arguments:[NSArray arrayWithObject:[[track persistentID] description]]];
            
            playedCount = [result objectForKey:@"playedCount"];
    
            iTunesEVdK *type;
            
            if([track seasonNumber] == 0)
                type = iTunesEVdKMovie;
            else
                type = iTunesEVdKTVShow;
           
            if(playedCount == nil) {

                [self updateTrackCount:track scrobbled:NO];

                if([track playedCount] > 0) {
          
                    videos = [self extendVideoBatch:track videos:videos];
                }
                
            } else if([playedCount integerValue] < [track playedCount]) {
      
                videos = [self extendVideoBatch:track videos:videos];
                
                [self updateTrackCount:track scrobbled:YES];
            }
        });
    }
    
    dispatch_group_notify(self.dispatchGroup, self.queue, ^{

        if([videos count] > 0)
            [api batch:videos];
    });
}

- (NSMutableDictionary *)extendVideoBatch:(iTunesTrack *)track videos:(NSMutableDictionary *)videoDict {
    
    if([track seasonNumber] == 0) {
        
        NSDictionary *movie = [NSDictionary dictionaryWithObjectsAndKeys:
                               [track name], @"title",
                               [NSString stringWithFormat:@"%ld",(long)[track year]],@"year",
                               [NSString stringWithFormat:@"%@",[ITUtil watchedDate:[track playedDate]]], @"watched_at",
                               nil];
        
        [[videoDict objectForKey:@"movies"] addObject:movie];
        
    } else {
        
        NSDictionary *episode = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[ITUtil watchedDate:[track playedDate]]], @"watched_at", [NSString stringWithFormat:@"%ld",(long)[track episodeNumber]],@"number", nil];
        NSDictionary *season = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)[track episodeNumber]],@"number", [NSMutableArray array], @"episodes", nil];
        [[season objectForKey:@"episodes"] addObject:episode];
        
        NSDictionary *show = [NSDictionary dictionaryWithObjectsAndKeys:[track show], @"title", [NSString stringWithFormat:@"%ld",(long)[track year]], @"year", [NSMutableArray array], @"seasons" , nil];
        [[show objectForKey:@"seasons"] addObject:season];
        
        [[videoDict objectForKey:@"shows"] addObject:show];
    }
    
    return videoDict;
}

- (void)updateTrackCount:(iTunesTrack *)track scrobbled:(BOOL)scrobble {
 
    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[[track persistentID] description], @"id", [NSNumber numberWithInt:(int) [track playedCount]], @"played", [NSNumber numberWithBool:scrobble], @"scrobble", nil];
    
    NSLog(@"id: %@, played: %@", [argsDict objectForKey:@"id"], [argsDict objectForKey:@"played"]);
    
    ITDb *db = [ITDb new];
    
    [db executeUpdateUsingQueue:@"REPLACE INTO library (persistentId, playedCount, scrobbled) VALUES (:id, :played, :scrobble)" arguments:argsDict];
}

@end
