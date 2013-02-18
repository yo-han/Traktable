//
//  IMDB.h
//  iTraktor
//
//  Created by Johan Kuijt on 13-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMDB : NSObject

+ (NSString * )getImdbIdByTitle:(NSString *)title year:(NSString *)aYear;

@end
