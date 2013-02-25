//
//  ITMovie.h
//  Traktable
//
//  Created by Johan Kuijt on 04-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

@interface ITMovie : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *persistentID;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic) NSInteger playCount;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger duration;
@property (nonatomic) iTunesEVdK videoKind;

+(ITMovie *)movieWithCurrentTunesTrack:(iTunesTrack *)iTunesTrack;

@end
