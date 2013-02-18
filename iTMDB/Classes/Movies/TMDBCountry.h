//
//  TMDBCountry.h
//  iTMDb
//
//  Created by Alessio Moiso on 16/01/13.
//  Copyright (c) 2013 MrAsterisco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMDBCountry : NSObject

@property NSString *isoCode;
@property NSString *name;

+ (TMDBCountry*)countryWithISOCode:(NSString*)code andName:(NSString*)name;

- (id)initWithISOCode:(NSString*)code andName:(NSString*)name;

@end
