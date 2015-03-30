//
//  ITUtil.m
//  Traktable
//
//  Created by Johan Kuijt on 08-08-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ITUtil

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

+ (NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int) strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

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
    [weekDayFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [weekDayFormatter setDateFormat:@"EEEE dd MMMM, yyyy"];
    
    NSDate *date = [self stringToDateTime:dateStr];
    NSString *weekDay =  [weekDayFormatter stringFromDate:date];
    
    return weekDay;
}

+ (NSString *)watchedDate:(NSDate *)date {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSString *)stringToTime:(NSString *)dateStr {
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [timeFormatter setDateFormat:@"HH:mm"];
    
    NSDate *date = [self stringToDateTime:dateStr];
    NSString *time =  [timeFormatter stringFromDate:date];
    
    return time;
}

+(NSDate *)appBuildDate {
    
    NSString *compileDate = [NSString stringWithUTF8String:__DATE__];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM d yyyy"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:usLocale];
    
    NSDate *aDate = [df dateFromString:compileDate];
    
    return aDate;
}

@end
