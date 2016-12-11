//
//  NKSocketStream.h
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKHTTPRequest.h"

#include <unistd.h>

@interface NKSocketStream : NSObject

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port NS_DESIGNATED_INITIALIZER;

- (void)write:(const char *)data;

- (NSData *)read;

- (void)close;

@end
