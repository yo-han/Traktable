//
//  ITMoviePoster.m
//  Traktable
//
//  Created by Johan Kuijt on 08-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITMoviePoster.h"
#import "ITConstants.h"
#import "ITUtil.h"
#import "NSImage+MGCropExtensions.h"

@interface ITMoviePoster()

struct ITPosterSize {
    float width;
    float height;
};

@property (nonatomic, assign) NSString *sizeName;
@property (nonatomic, assign) struct ITPosterSize sizeValues;

@end

@implementation ITMoviePoster

struct ITPosterSize ITMoviePosterSizeSmallSize = {100.0, 150.0};
struct ITPosterSize ITMoviePosterSizeMediumSize = {500.0, 750.0};

- (NSImage *)getPoster:(NSNumber *)movieId withSize:(ITMoviePosterSize)size {
    
    [self setSize:size];
    
    @autoreleasepool {
        
        NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/movies/%@/%@.jpg", movieId, self.sizeName]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
            return [[NSImage alloc] initWithContentsOfFile:imagePath];
        else
            return nil;
    }
}

- (NSImage *)poster:(NSNumber *)movieId withUrl:(NSString *)urlString size:(ITMoviePosterSize)size {
    
    [self setSize:size];
    
    NSString *imagePath = [[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/movies/%@/%@.jpg", movieId, self.sizeName]];

    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        return [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    if (urlString == (id)[NSNull null] || urlString.length == 0 )
        return nil;
    
    [ITUtil createDir:[[ITConstants applicationSupportFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/movies/%@", movieId]]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    NSImage *imageScaled;
    
    if(size != ITMoviePosterSizeOriginal)
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

- (void)setSize:(ITMoviePosterSize)size {
    
    switch (size) {
        case ITMoviePosterSizeSmall:
            _sizeName = @"small";
            _sizeValues = ITMoviePosterSizeSmallSize;
            break;
        case ITMoviePosterSizeMedium:
            _sizeName = @"medium";
            _sizeValues = ITMoviePosterSizeMediumSize;
            break;
        default:
            _sizeName = @"original";
            break;
    }
}
@end
