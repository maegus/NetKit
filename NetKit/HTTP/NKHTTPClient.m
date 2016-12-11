//
//  NKHTTPClient.m
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import "NKHTTPClient.h"
#import "NKHTTPRequest.h"
#import "NKSocketStream.h"
#import "NKHTTPMessage.h"

@implementation NKHTTPClient

- (NKHTTPClient *(^)(NKHTTPRequest *))newCall {
    return ^(NKHTTPRequest *request) {
        NKSocketStream *socket = [[NKSocketStream alloc] initWithHost:request.host port:request.port];
        [socket write:request.rawValue.UTF8String];
//        NSLog(@"%@", [socket read]);
        NKHTTPMessage *message = [[NKHTTPMessage alloc] init];
        [message appendMessage:[socket read]];
        return self;
    };
}

@end
