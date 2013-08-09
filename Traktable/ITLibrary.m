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
#import "ITMoviePoster.h"
#import "ITDb.h"
#import "ITUtil.h"

@interface ITLibrary()

- (id)init;
- (NSArray *)checkTracks:(NSArray *)tracks;

@property dispatch_queue_t queue;

@end

@implementation ITLibrary

@synthesize iTunesBridge;
@synthesize queue=_queue;
@synthesize dbFilePath;
@synthesize firstImport;

- (id)init {
    
    iTunesBridge = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    ITApi *api = [ITApi new];
    
    NSString *appSupportPath = [ITConstants applicationSupportFolder];
    [ITUtil createDir:appSupportPath];
    
    dbFilePath = [appSupportPath stringByAppendingPathComponent:@"iTraktor.db"];
    
    bool b = [self dbExists];
    
    if([api testAccount] && b == NO) {
        
        [self resetDb];
    }
    
    _queue = dispatch_queue_create("traktable.sync.queue", NULL);
    
    ITDb *db = [ITDb new];
    [db executeAndGetOneResult:@"SELECT playedCount FROM library" arguments:nil];

    if([db error]) {
        
        NSLog(@"Reset db is caused by error: %@", [db lastErrorMessage]);
        
        [[NSFileManager defaultManager] removeItemAtPath:dbFilePath error:nil];
        [self resetDb];
        
    } else if([db databaseNeedsMigration]) {
        
        [db migrateDatabase];
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
    
    ITApi *api = [ITApi new];
    firstImport = YES;
    
    NSArray *movies = [self getVideos:iTunesESpKMovies noCheck:YES];
    NSArray *shows = [self getVideos:iTunesESpKTVShows noCheck:YES];

    NSArray *seenMovies = [self checkTracks:movies];
    if([seenMovies count] > 0)
        [api seen:seenMovies type:iTunesEVdKMovie video:nil];
    
    [self checkTracks:shows];
    
    dispatch_sync(self.queue, ^{
        printf("Import done.");
    });
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

- (void)syncTrakt {
    
    ITApi *api = [ITApi new];

    NSArray *movies = [api watchedSync:iTunesEVdKMovie extended:@"1"];
        
    for(NSDictionary *movie in movies) {
        
        NSString *posterUrl = [[movie objectForKey:@"images"] objectForKey:@"poster"];
        
        NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[movie objectForKey:@"tmdb_id"], @"tmdb_id", [movie objectForKey:@"imdb_id"],@"imdb_id",[movie objectForKey:@"year"],@"year", posterUrl,@"poster",[movie objectForKey:@"plays"],@"traktPlays",[movie objectForKey:@"released"],@"released",[movie objectForKey:@"runtime"],@"runtime",[movie objectForKey:@"title"],@"title",[movie objectForKey:@"overview"],@"overview",[movie objectForKey:@"tagline"],@"tagline",[movie objectForKey:@"url"],@"traktUrl",[movie objectForKey:@"trailer"],@"trailer",[movie objectForKey:@"genres"],@"genres", nil];
        
        ITDb *db = [ITDb new];
        
        if([db executeAndGetOneResult:@"SELECT 'x' FROM movies WHERE tmdb_id = :id" arguments:[NSArray arrayWithObject:[movie objectForKey:@"tmdb_id"]]] != nil)
            continue;
        
        [db executeUpdateUsingQueue:@"INSERT INTO movies (tmdb_id, imdb_id, year, poster, traktPlays, released, runtime, title, overview, tagline, traktUrl, trailer, genres) VALUES (:tmdb_id, :imdb_id, :year, :poster, :traktPlays, :released, :runtime, :title, :overview, :tagline, :traktUrl, :trailer, :genres)"  arguments:argsDict];
        
        NSNumber *lastId = [db lastInsertRowId];
        
        if([lastId intValue] == 0)
            continue;
        
        dispatch_async(self.queue,
        ^{
            ITMoviePoster *poster = [ITMoviePoster new];
       
            [poster poster:lastId withUrl:posterUrl size:ITMoviePosterSizeSmall];
            [poster poster:lastId withUrl:posterUrl size:ITMoviePosterSizeMedium];
            [poster poster:lastId withUrl:posterUrl size:ITMoviePosterSizeOriginal];
        });
    }
}

- (NSArray *)checkTracks:(NSArray *)tracks {

    NSMutableArray *seenVideos = [[NSMutableArray alloc] init];
    ITVideo *video = [ITVideo new];
    ITApi *api = [ITApi new];
       
    int i;
    for(i = 0; i < [tracks count]; i++) {
        
        __block id playedCount;
        
        dispatch_async(self.queue, ^{
            
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
                    
                    
                }

                scrobbleVideo = [video getVideoByType:track type:type];
                
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
                    [api library:[NSArray arrayWithObject:videoDict] type:type video:scrobbleVideo];
                
            } else if([playedCount integerValue] < [track playedCount]) {
                                   
                id scrobbleVideo = [video getVideoByType:track type:type];
                [api updateState:scrobbleVideo state:@"scrobble"];
                
                [self updateTrackCount:track scrobbled:YES];
            }

        });
    
    }
    
    return seenVideos;
}

- (void)updateTrackCount:(iTunesTrack *)track scrobbled:(BOOL)scrobble {
 
    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:[[track persistentID] description], @"id", [NSNumber numberWithInt:(int) [track playedCount]], @"played", [NSNumber numberWithBool:scrobble], @"scrobble", nil];
    
    NSLog(@"id: %@, played: %@", [argsDict objectForKey:@"id"], [argsDict objectForKey:@"played"]);
    
    ITDb *db = [ITDb new];
    
    [db executeUpdateUsingQueue:@"REPLACE INTO library (persistentId, playedCount, scrobbled) VALUES (:id, :played, :scrobble)" arguments:argsDict];
}

@end
