//
//  ITEpisodeScreen.m
//  Traktable
//
//  Created by Johan Kuijt on 30-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITEpisodeScreen.h"
#import "ITConstants.h"
#import "ITUtil.h"
#import "NSImage+MGCropExtensions.h"

@interface ITEpisodeScreen()

struct ITEpisodeScreenSize {
    float width;
    float height;
};

@property (nonatomic, assign) NSString *sizeName;
@property (nonatomic, assign) struct ITEpisodeScreenSize sizeValues;

@end

@implementation ITEpisodeScreen

struct ITEpisodeScreenSize ITEpisodeScreenSizeSmallSize = {100.0, 55.0};
struct ITEpisodeScreenSize ITEpisodeScreenSizeMediumSize = {200.0, 110.0};

- (NSImage *)getScreen:(NSNumber *)showId season:(NSNumber *)season episode:(NSNumber *)episode withSize:(ITEpisodeScreenSize)size {
    
    [self setSize:size];
    
    NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/episodes/%@/S%@/E%@_%@.jpg", showId, season, episode, self.sizeName]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    else
        return nil;
}

- (NSImage *)screen:(NSNumber *)showId season:(NSNumber *)season episode:(NSNumber *)episode withUrl:(NSString *)urlString size:(ITEpisodeScreenSize)size {
    
    [self setSize:size];
    
    NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/episodes/%@/S%@/E%@_%@.jpg", showId, season, episode, self.sizeName]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    [ITUtil createDir:[[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/episodes/%@/S%@", showId, season]]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    NSImage *imageScaled;
    
    if(size != ITEpisodeScreenSizeOriginal)
        imageScaled = [image imageScaledToFitSize:NSMakeSize(self.sizeValues.width, self.sizeValues.height)];
    else
        imageScaled = image;
    
    NSData *scaledImageData = [imageScaled TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:scaledImageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    scaledImageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    
    [scaledImageData writeToFile:imagePath atomically:YES];
    
    return imageScaled;
}

- (void)setSize:(ITEpisodeScreenSize)size {
    
    switch (size) {
        case ITEpisodeScreenSizeSmall:
            _sizeName = @"small";
            _sizeValues = ITEpisodeScreenSizeSmallSize;
            break;
        case ITEpisodeScreenSizeMedium:
            _sizeName = @"medium";
            _sizeValues = ITEpisodeScreenSizeMediumSize;
            break;
        default:
            _sizeName = @"original";
            break;
    }
}

@end
