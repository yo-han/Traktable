//
//  ITTableGroupDateCellView.m
//  Traktable
//
//  Created by Johan Kuijt on 23-09-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "ITTableGroupDateCellView.h"

@implementation ITTableGroupDateCellView

@end

@implementation ITDateGroupHeader

- (id)initWithDateString:(NSString *)date {
    
    self = [super init];
    if (self) {
        _date = date;
    }
    return self;
}
@end
