//
//  ITTrakt.h
//  Traktable
//
//  Created by Johan Kuijt on 29-03-15.
//  Copyright (c) 2015 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ITTraktConstants.h"

@interface ITTrakt : NSObject

+ (instancetype)sharedClient;

- (void)POST:(NSString *)url withParameters:(NSDictionary *)params completionHandler:(void (^)(id , NSError *))completionBlock;

- (BOOL)traktUserAuthenticated;

@end
