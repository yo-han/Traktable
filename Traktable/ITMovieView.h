//
//  ITMovieView.h
//  Traktable
//
//  Created by Johan Kuijt on 25-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ITMovieViewBox : NSBox
@end

@interface ITMovieScrollView : NSScrollView
@end

@interface ITMovieCollectionViewItem : NSCollectionViewItem

@property (nonatomic, retain) IBOutlet NSString *movieTitle;
@property (nonatomic, retain) IBOutlet NSImage *moviePoster;

- (id)copyWithZone:(NSZone *)zone;
- (void)setRepresentedObject:(id)object;
- (void)setSelected:(BOOL)flag;
- (void)awakeFromNib;

@end

@interface ITMovieView : NSViewController <NSCollectionViewDelegate> {
    
    IBOutlet NSCollectionView *collectionView;
    IBOutlet NSArrayController *arrayController;
    NSMutableArray *movies;
}

@property (retain) NSMutableArray *movies;

@end
