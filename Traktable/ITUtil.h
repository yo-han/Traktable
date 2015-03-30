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

+ (NSString *)uuid;
+ (NSString*)md5HexDigest:(NSString*)input;

+ (NSDate *)stringToDateTime:(NSString *)dateStr;
+ (NSString *)localeDateString:(NSString *)dateStr;
+ (NSString *)stringToTime:(NSString *)dateStr;
+ (NSString *)watchedDate:(NSDate *)date;
+ (NSDate *)appBuildDate;

@end
