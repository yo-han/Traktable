//
//  NSData+Additions.h
//
//  Created by Samuel Chow on 4/26/11.
//  Copyright 2011 MobyFab. All rights reserved.
//

@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end

