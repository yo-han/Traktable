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

#import <CoreServices/CoreServices.h>


@interface ITVideo()

@property (nonatomic, retain) iTunesApplication *iTunesBridge;
@property (nonatomic, retain) VLCApplication *VLCBridge;

@end

@implementation ITVideo

- (id)init {
   
    _iTunesBridge = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    _VLCBridge = [SBApplication applicationWithBundleIdentifier:@"org.videolan.vlc"];
    
    return self;
}

- (id)getCurrentlyPlaying:(ITVideoPlayer)player {
    
    if(player == ITPlayerITunes)
        return [self getITunesVideoByType:[self.iTunesBridge currentTrack] type:[[self.iTunesBridge currentTrack] videoKind]];
    else if(player == ITPlayerVLC)
        return [self getVLCVideo:[self.VLCBridge pathOfCurrentItem]];
    else
        return nil;
}

- (BOOL)isVideoPlaying:(ITVideoPlayer)player {
    
    if(player == ITPlayerITunes) {
    
        iTunesEVdK type = [[self.iTunesBridge currentTrack] videoKind];
        if(type == iTunesEVdKTVShow || type == iTunesEVdKMovie)
            return YES;
    }
    
    return NO;
}

- (id)getITunesVideoByType:(iTunesTrack *)track type:(iTunesEVdK)aType {
    
    id video;
    
    if(aType == iTunesEVdKTVShow) {
        
        video = [ITTVShow showWithCurrentTunesTrack:track];
        
    } else if (aType == iTunesEVdKMovie) {
        
        video = [ITMovie movieWithCurrentTunesTrack:track];
        
        
    }
    
    return video;
}

- (id)getVLCVideo:(NSString *)track {
    
    id video;
    
    NSLog(@"To build a VLC MetaData reader using Guessit and something iTunes metadata readerish?");
    
    return video;
}

@end
