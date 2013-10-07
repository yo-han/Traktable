//
//  ITTVShowView.h
//  Traktable
//
//  Created by Johan Kuijt on 07-10-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>

@interface ITTVShowView : NSViewController
{
    IBOutlet IKImageBrowserView*	imageBrowser;
    NSMutableArray*					images;
    NSMutableArray*					importedImages;
}

@end
