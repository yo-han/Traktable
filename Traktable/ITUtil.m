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

+ (NSString *)localeDateString:(NSString *)dateStr {
    
    NSDateFormatter* weekDayFormatter = [[NSDateFormatter alloc] init];
    [weekDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [weekDayFormatter setDateFormat:@"EEEE dd MMMM, yyyy"];
    
    NSDate *date = [self stringToDateTime:dateStr];
    NSString *weekDay =  [weekDayFormatter stringFromDate:date];
    
    return weekDay;
}

+ (NSString *)stringToTime:(NSString *)dateStr {
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [timeFormatter setDateFormat:@"HH:mm"];
    
    NSDate *date = [self stringToDateTime:dateStr];
    NSString *time =  [timeFormatter stringFromDate:date];
    
    return time;
}

@end
