    //
    //  NKSocketStream.m
    //  NetKit
    //
    //  Created by Draveness on 11/6/16.
    //  Copyright © 2016 Draveness. All rights reserved.
    //

#import "NKSocketStream.h"

#include <unistd.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netdb.h>

@implementation NKSocketStream

NSInteger const NKSocketStreamBufferSize = 100 * 1024;

+ (void)sendRequest:(NKHTTPRequest *)request completion:(void (^)(NSData *))completion {

    int sockfd = 0;
    if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        NSLog(@"socket error");

    struct addrinfo hints, *res;

    bzero(&hints, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;

    getaddrinfo(request.host.UTF8String, request.port.stringValue.UTF8String, &hints, &res);
    connect(sockfd, res->ai_addr, res->ai_addrlen);

    const char *requestData = [request.rawValue UTF8String];
    write(sockfd, requestData, strlen(requestData));

    char buf[NKSocketStreamBufferSize];
    ssize_t total = 0, byte_count = 0;

    char *pointer = buf;

    byte_count = read(sockfd, pointer, NKSocketStreamBufferSize - total - 1);

    total += byte_count;
    pointer += byte_count;
    buf[total] = 0;


    close(sockfd);

    NSLog(@"%@", [NSString stringWithUTF8String:buf]);

    NSData *returnData = [NSData dataWithBytes:buf length:total];

    completion(returnData);
}

@end
