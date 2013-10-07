//
//  ITMovieView.h
//  Traktable
//
//  Created by Johan Kuijt on 25-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>

@interface ITMovieView : NSViewController
{
    IBOutlet IKImageBrowserView*	imageBrowser;
    NSMutableArray*					images;
    NSMutableArray*					importedImages;
}

@end
