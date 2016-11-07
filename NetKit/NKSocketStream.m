    //
    //  NKSocketStream.m
    //  NetKit
    //
    //  Created by Draveness on 11/6/16.
    //  Copyright © 2016 Draveness. All rights reserved.
    //

#import "NKSocketStream.h"

#include <stdlib.h>
#include <sys/socket.h>
#include <netdb.h>

@interface NKSocketStream ()

@property (nonatomic, assign) int sockfd;

@end

@implementation NKSocketStream

NSInteger const NKSocketStreamBufferSize = 100 * 1024;

- (instancetype)initWithHost:(NSString *)host port:(NSNumber *)port {
    if (self = [super init]) {
        if ( (_sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
            NSLog(@"socket error");

        struct addrinfo hints, *res;

        bzero(&hints, sizeof(hints));
        hints.ai_family = AF_INET;
        hints.ai_socktype = SOCK_STREAM;

        getaddrinfo(host.UTF8String, port.stringValue.UTF8String, &hints, &res);
        if (connect(_sockfd, res->ai_addr, res->ai_addrlen) < 0) {
            NSLog(@"connect error %d", errno);

        }

    }
    return self;
}

- (void)write:(const char *)data {
    write(_sockfd, data, strlen(data));
}

- (NSString *)read {
    char buffer[NKSocketStreamBufferSize];
    NSInteger count = 0;
    if ( (count = read(_sockfd, buffer, sizeof(buffer))) < 0) {
        NSLog(@"read error %d", errno);
    }
    return [NSString stringWithUTF8String:buffer];
}

- (void)close {
    close(_sockfd);
}

@end
