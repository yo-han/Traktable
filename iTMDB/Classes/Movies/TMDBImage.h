//
//  TMDBImage.h
//  iTMDb
//
//  Created by Alessio Moiso on 14/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMDB.h"
#import "TMDBImageDelegate.h"

typedef enum {
	TMDBImageTypePoster,
	TMDBImageTypeBackdrop
} TMDBImageType;

@interface TMDBImage : NSObject <TMDBRequestDelegate>

@property NSURL *address;
@property BOOL ready;
@property TMDB *context;
@property TMDBRequest *configurationRequest;
@property id<TMDBImageDelegate> delegate;

+ (TMDBImage*)imageWithDictionary:(NSDictionary*)image context:(TMDB*)aContext delegate:(id<TMDBImageDelegate>)del;

- (id)initWithAddress:(NSURL*)address context:(TMDB*)aContext delegate:(id<TMDBImageDelegate>)del;

@end
