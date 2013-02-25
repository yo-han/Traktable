//
//  video.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-01-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITVideo.h"
#import "ITTVShow.h"
#import "ITMovie.h"
#import "ITLibrary.h"

@implementation ITVideo

@synthesize iTunesBridge;

- (id)init {
   
    iTunesBridge = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    return self;
}

- (id)getCurrentlyPlaying {
    
    return [self getVideoByType:[iTunesBridge currentTrack] type:[[iTunesBridge currentTrack] videoKind]];
}

- (BOOL)isVideoPlaying {
    
    iTunesEVdK type = [[iTunesBridge currentTrack] videoKind];
    if(type != iTunesEVdKTVShow && type != iTunesEVdKMovie)
        return false;
    
    return true;
}

- (id)getVideoByType:(iTunesTrack *)track type:(iTunesEVdK)aType {
    
    id video;
    
    if(aType == iTunesEVdKTVShow) {
        
        video = [ITTVShow showWithCurrentTunesTrack:track];
        
    } else if (aType == iTunesEVdKMovie) {
        
        video = [ITMovie movieWithCurrentTunesTrack:track];
        
        
    }
    
    return video;
}

@end
