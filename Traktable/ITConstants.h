//
//  ITConstants.h
//  Traktable
//
//  Created by Johan Kuijt on 06-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kITHistoryTableReloadNotification @"ITHistoryTableReload"
#define kITHistoryNeedsUpdateNotification @"ITHistoryNeedsUpdate"
#define kITMovieNeedsUpdateNotification @"ITSyncUpdateMovie"
#define kITTVShowNeedsUpdateNotification @"ITSyncUpdateShow"
#define kITTVShowEpisodeNeedsUpdateNotification @"ITSyncUpdateEpisode"
#define kITUpdateProgressWindowNotification @"ITUpdateProgressWindow"
#define kITMigrateProgressWindowNotification @"ITMigrateWindowUpdate"

@interface ITConstants : NSObject

typedef enum ITSourceListIdentifier : NSUInteger {
    ITMovies = 0,
    ITTVShows = 1,
    ITHistoryMovies = 2,
    ITHistoryTVShows = 3,
    ITErrorList = 4,
    ITQueueList = 5
} ITSourceListIdentifier;

typedef NS_ENUM(NSUInteger, ITTableViewCellType) {
    ITTableViewMovieHistoryCell = 0,
    ITTableViewTVShowHistoryCell = 1,
    ITTableViewErrorCell = 2,
    ITTableViewUnknownCell = NSUIntegerMax
};

+ (NSString *)applicationSupportFolder;
+ (NSDictionary *)tableViewCellTypes;

+ (BOOL)firstBoot;
+ (BOOL)traktReachable;

@end
