//
//  NSString+Helper.m
//  iTVDb
//
//  Created by Kevin Tuhumury on 7/10/12.
//  Copyright (c) 2012 Thmry. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

+ (NSArray *)pipedStringToArray:(NSString *)string
{
    if ([string hasPrefix:@"|"])
    {
        string = [string substringFromIndex:1];
    }
    if ([string hasSuffix:@"|"])
    {
        string = [string substringToIndex:[string length] - 1];
    }
    if ([string rangeOfString:@"|"].location == NSNotFound)
    {
        return [NSArray arrayWithObject:string];
    }
    else
    {
        return [string componentsSeparatedByString:@"|"];
    }
}

+ (NSDate *)stringToDate:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter dateFromString:string];
}

@end