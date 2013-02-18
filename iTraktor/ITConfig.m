//
//  ITConfig.m
//  iTraktor
//
//  Created by Johan Kuijt on 18-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITConfig.h"

@implementation ITConfig

+ (NSDictionary *)getConfigFile {
    
    NSString *configPath = [NSString stringWithFormat:@"%@/Contents/Resources/config.plist",[[NSBundle mainBundle] bundlePath]];

    NSData *plistData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
    
    if(!plist) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Config file is missing."];
        [alert runModal];
    }
    
    return plist;
}

@end
