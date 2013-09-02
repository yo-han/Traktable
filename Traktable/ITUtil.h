//
//  ITUtil.h
//  Traktable
//
//  Created by Johan Kuijt on 08-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITUtil : NSObject

+ (void)createDir:(NSString *)dir;

+ (NSDate *)stringToDateTime:(NSString *)dateStr;

@end
