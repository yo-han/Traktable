//
//  ITUtil.m
//  Traktable
//
//  Created by Johan Kuijt on 08-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITUtil.h"

@implementation ITUtil

+ (void)createDir:(NSString *)dir {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if(![fileManager fileExistsAtPath:dir])
        if(![fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", dir);
}

+ (NSDate *)stringToDateTime:(NSString *)dateStr {
        
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm +0000"];
    
    NSDate *date = [dateFormat dateFromString:dateStr];

    return date;
}

@end
