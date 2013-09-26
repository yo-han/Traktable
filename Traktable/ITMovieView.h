//
//  ITMovieView.h
//  Traktable
//
//  Created by Johan Kuijt on 25-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITMovieView : NSViewController

@property(nonatomic, strong) IBOutlet NSCollectionView *collectionView;

- (void)reload;

@end
