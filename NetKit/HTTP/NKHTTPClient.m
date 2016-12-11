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
#import "NKHTTPResponse.h"

@implementation NKHTTPClient

- (NKHTTPClient *(^)(NKHTTPRequest *))newCall {
    return ^(NKHTTPRequest *request) {
        NKSocketStream *socket = [[NKSocketStream alloc] initWithHost:request.host port:request.port];
        [socket write:request.rawValue.UTF8String];
        NKHTTPResponse *response = [[NKHTTPResponse alloc] init];
        while (![response appendData:[socket read]]) {

        }
        NSLog(@"%lu", (unsigned long)response.body.length);

        return self;
    };
}

@end
