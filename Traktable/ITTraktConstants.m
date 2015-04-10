//
//  ITTraktConstants.m
//  Traktable
//
//  Created by Johan Kuijt on 29-03-15.
//  Copyright (c) 2015 Mustacherious. All rights reserved.
//

#import "ITTraktConstants.h"

NSString * const kITTraktBaseURL = @"https://api-v2launch.trakt.tv";

NSString * const kITTraktOAuthUrl = @"/oauth/token";

NSString * const kITTraktScrobbleUrl = @"/scrobble/";

NSString * const kITTraktSyncHistoryUrl = @"/sync/history";

NSString * const kITTraktSyncWatchedMoviesUrl = @"/sync/watched/movies";

NSString * const kITTraktSyncWatchedShowsUrl = @"/sync/watched/shows";

NSString * const kITTraktSyncWatchedMoviesExtendedUrl = @"/movies/%@?extended=full,images";

NSString * const kITTraktSyncWatchedShowsExtendedUrl = @"/shows/%@?extended=full,images";

NSString * const kITTraktSyncWatchedShowsEpisodeExtendedUrl = @"/shows/%@/seasons/%@/episodes/%@?extended=full,images";

NSString * const kITTraktSearchUrl = @"/search?query=%@&type=%@%@";