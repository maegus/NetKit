//
//  NKHTTPRequest.m
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import "NKHTTPRequest.h"

@interface NKHTTPRequest ()

@property (nonatomic, strong) NSNumber *version;

@end

@implementation NKHTTPRequest

- (instancetype)init {
    if (self = [self initWithURL:@""]) {
    }
    NSAssert(NO, @"Invalid initializer use -initWithURL instead.");
    return self;
}

- (instancetype)initWithURL:(NSString *)urlString {
    if (self = [super init]) {
        _version = @1.1;
        _method = @"GET";
        _url = [NSURL URLWithString:urlString];
        _port = _url.port ?: @80;
        _host = _url.host;
        _resource = _url.relativePath.length > 0 ? _url.relativePath : @"/";

        _headers = [[NSMutableDictionary alloc] init];

        [_headers setValue:_host forKey:@"Host"];
    }
    return self;
}

- (NSString *)rawValue {
    NSString *requestLine = [NSString stringWithFormat:@"%@ %@ HTTP/%@", self.method, self.resource, self.version];

    NSString *headerFields = @"";
    if (self.headers.count > 0) {
        NSMutableArray *headerArray = [[NSMutableArray alloc] init];
        for (NSString *key in self.headers) {
            NSString *value = self.headers[key];
            [headerArray addObject:[NSString stringWithFormat:@"%@: %@", key, value]];
        }
        headerFields = [[headerArray componentsJoinedByString:@"\n"] stringByAppendingString:@"\r\n"];
    }

    return [NSString stringWithFormat:@"%@\r\n%@\r\n", requestLine, headerFields];
}

@end
