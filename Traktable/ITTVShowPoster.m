//
//  ITTVShowPoster.m
//  Traktable
//
//  Created by Johan Kuijt on 26-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTVShowPoster.h"
#import "ITConstants.h"
#import "ITUtil.h"
#import "NSImage+MGCropExtensions.h"

@interface ITTVShowPoster()

struct ITPosterSize {
    float width;
    float height;
};

@property (nonatomic, assign) NSString *sizeName;
@property (nonatomic, assign) struct ITPosterSize sizeValues;

@end

@implementation ITTVShowPoster

struct ITPosterSize ITTVShowPosterSizeSmallSize = {100.0, 150.0};
struct ITPosterSize ITTVShowPosterSizeMediumSize = {500.0, 750.0};

- (NSImage *)getPoster:(NSNumber *)showId withSize:(ITTVShowPosterSize)size {
    
    [self setSize:size];
    
    NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/tvshows/%@/%@.jpg", showId, self.sizeName]];

    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    else
        return nil;
}

- (NSImage *)poster:(NSNumber *)showId withUrl:(NSString *)urlString size:(ITTVShowPosterSize)size {
    
    [self setSize:size];
    
    NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/tvshows/%@/%@.jpg", showId, self.sizeName]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    [ITUtil createDir:[[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/tvshows/%@", showId]]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    NSImage *imageScaled;
    
    if(size != ITTVShowPosterSizeOriginal)
        imageScaled = [image imageCroppedToFitSize:NSMakeSize(self.sizeValues.width, self.sizeValues.height)];
    else
        imageScaled = image;
    
    NSData *scaledImageData = [imageScaled TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:scaledImageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    scaledImageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    
    [scaledImageData writeToFile:imagePath atomically:YES];
    
    return imageScaled;
}

- (void)setSize:(ITTVShowPosterSize)size {
    
    switch (size) {
        case ITTVShowPosterSizeSmall:
            _sizeName = @"small";
            _sizeValues = ITTVShowPosterSizeSmallSize;
            break;
        case ITTVShowPosterSizeMedium:
            _sizeName = @"medium";
            _sizeValues = ITTVShowPosterSizeMediumSize;
            break;
        default:
            _sizeName = @"original";
            break;
    }
}

@end
