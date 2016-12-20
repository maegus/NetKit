//
//  NKHTTPResponse.m
//  NetKit
//
//  Created by Draveness on 12/7/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import "NKHTTPResponse.h"

@interface NKHTTPHelper: NSObject

@end

@implementation NKHTTPHelper

+ (NSString *)nextLine:(NSString *)message {
    return [NKHTTPHelper scanUpToString:@"\r\n" fromString:message];
}

+ (NSString *)httpHeader:(NSString *)message {
    return [NKHTTPHelper scanUpToString:@"\r\n\r\n" fromString:message];
}

+ (NSString *)scanUpToString:(NSString *)upToString fromString:(NSString *)message {
    NSString *result = nil;
    NSScanner *scanner = [[NSScanner alloc] initWithString:message];
    [scanner scanUpToString:upToString intoString:&result];
    return result;
}

@end

@interface NKHTTPResponse ()

@property (nonatomic, copy) NSMutableData *rawData;

@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign, readwrite) NSUInteger statusCode;
@property (nonatomic, strong, readwrite) NSString *reasonPhrase;
@property (nonatomic, strong, readwrite) NSDictionary *headerFields;
@property (nonatomic, strong, readwrite) NSData *body;

@property (nonatomic, assign, readonly) NSUInteger contentLength;

@end

@implementation NKHTTPResponse {
    BOOL _parsedHeader;
    NSString *_rawHTTPHeader;

    NSUInteger _index;
    NSUInteger _headerEndIndex;
    NSUInteger _bodyStartIndex;
}

- (instancetype)init {
    if (self = [super init]) {
        _rawData = [[NSMutableData alloc] init];
        _parsedHeader = NO;
        _index = 0;
        _headerEndIndex = 0;
        _bodyStartIndex = 0;
    }
    return self;
}

- (void)parse:(NSData *)data {
    [self.rawData appendData:data];

    if (_headerEndIndex) return;

    NSUInteger bytesCount = self.rawData.length;
    const char *bytes = self.rawData.bytes;
    for (; _index < bytesCount; _index++) {
        if (bytes[_index] == 0x0D &&
            bytes[_index+1] == 0x0A &&
            bytes[_index+2] == 0x0D &&
            bytes[_index+3] ) {
            printf("%02X:%02X:%02X:%02X\n",
                   (unsigned char)bytes[_index],
                   (unsigned char)bytes[_index+1],
                   (unsigned char)bytes[_index+2],
                   (unsigned char)bytes[_index+3]
                   );
            _headerEndIndex = _index - 1;
            _bodyStartIndex = _index + 4;
            NSData *headerData = [self.rawData subdataWithRange:NSMakeRange(0, _headerEndIndex)];
            [self parseHTTPHeader:headerData];
        }
    }
}

- (BOOL)appendData:(NSData *)data {
    [self parse:data];

    if (!_headerEndIndex) return NO;

    @synchronized (self) {
        // Parse until received http header.

        // TODO: performace problem.
        NSData *data = [self.rawData subdataWithRange:NSMakeRange(_bodyStartIndex, self.rawData.length - _bodyStartIndex)];

        if (data.length >= self.contentLength) {
            self.body = [data subdataWithRange:NSMakeRange(0, self.contentLength)];
            return YES;
        }
    }

    return NO;
}

- (void)parseHTTPHeader:(NSData *)headerData {
    _rawHTTPHeader = [NSString stringWithUTF8String:headerData.bytes];

    // start-line, ex: HTTP/1.1 200 OK
    NSString *statusLine = [NKHTTPHelper scanUpToString:@"\r\n"
                                             fromString:_rawHTTPHeader];
//    NSLog(@"status-line: %@", statusLine);

    NSString *pattern = @"^HTTP/([0-9].[0-9])[\t ]([0-9]{3,3})[\t ]([a-zA-Z0-9]*)$";
    NSError *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:0
                                                                             error:&error];
    NSArray* matches = [regex matchesInString:statusLine
                                      options:0
                                        range:NSMakeRange(0, [statusLine length])];
    for (NSTextCheckingResult* match in matches) {
        if ([match numberOfRanges] != 3) {
            
        }
        NSRange versionRange = [match rangeAtIndex:1];
        NSRange statusCodeRange = [match rangeAtIndex:2];
        NSRange reasonPhraseRange = [match rangeAtIndex:3];
        self.version = [statusLine substringWithRange:versionRange];
        self.statusCode = [[statusLine substringWithRange:statusCodeRange] integerValue];
        self.reasonPhrase = [statusLine substringWithRange:reasonPhraseRange];
    }

    // header-field
    NSString *rawHeaderFields = [_rawHTTPHeader substringFromIndex:statusLine.length];
    NSArray *headerFields = [[NKHTTPHelper scanUpToString:@"\r\n\r\n"
                                               fromString:rawHeaderFields]
                             componentsSeparatedByString:@"\r\n"];
    NSLog(@"header-fields: %@", headerFields);

    NSMutableDictionary *tempHeaderFields = [[NSMutableDictionary alloc] init];
    for (NSString *headerField in headerFields) {
        NSString *fieldName = [NKHTTPHelper scanUpToString:@":"
                                                fromString:headerField];

        // Add @":".length == 1 to remove previous colon.
        NSString *fieldValue = [headerField substringFromIndex:fieldName.length + 1];

        // remove leading and trailing OWS in field value.
        fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([fieldName isEqualToString:@"Set-Cookie"]) continue;
        [tempHeaderFields setValue:fieldValue forKey:fieldName];
    }
    self.headerFields = [tempHeaderFields mutableCopy];
}

- (NSUInteger)contentLength {
    id value = [self.headerFields valueForKey:@"Content-Length"];
    return value ? [value integerValue] : 0;
}

- (NSString *)transferEncoding {
    // TODO: multiple Transfer-Encoding
    NSString *value = [self.headerFields valueForKey:@"Transfer-Encoding"];
    return value;
}

@end
