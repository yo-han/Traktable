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
#define kITHideProgressWindowNotification @"ITHideProgressWindow"

@interface ITConstants : NSObject

typedef enum ITSourceListIdentifier : NSUInteger {
    ITHistoryMovies,
    ITHistoryTVShows,
    ITErrorList
} ITSourceListIdentifier;

+ (NSString *)applicationSupportFolder;

+ (BOOL)firstBoot;

@end
