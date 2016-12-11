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

@property (nonatomic, copy) NSMutableString *plainMessage;

@property (nonatomic, strong) NSString *version;
@property (nonatomic, assign, readwrite) NSUInteger statusCode;
@property (nonatomic, strong, readwrite) NSString *reasonPhrase;
@property (nonatomic, strong, readwrite) NSDictionary *headerFields;
@property (nonatomic, strong, readwrite) NSData *body;

@property (nonatomic, assign, readonly) NSUInteger contentLength;

@end

@implementation NKHTTPResponse {
    BOOL _parsedHeader;
}

- (instancetype)init {
    if (self = [super init]) {
        _plainMessage = [[NSMutableString alloc] init];
        _parsedHeader = NO;
    }
    return self;
}

- (BOOL)appendMessage:(NSString *)message {
    if (message == nil) {
        return NO;
    }
    [self.plainMessage appendString:message];

    @synchronized (self) {
        // Parse until received http header.
        if (![self parseHTTPHeader]) return NO;

        NSString *rawHTTPHeader = [NKHTTPHelper httpHeader:self.plainMessage];
        NSString *body = [self.plainMessage substringFromIndex:rawHTTPHeader.length + 4];
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        if (data.length >= self.contentLength) {
            self.body = [data subdataWithRange:NSMakeRange(0, self.contentLength)];
            return YES;
        }
    }
    return NO;
}

- (BOOL)parseHTTPHeader {
    if (_parsedHeader) return YES;

    NSString *rawHTTPHeader = [NKHTTPHelper httpHeader:self.plainMessage];
    if (!rawHTTPHeader) {
        return NO;
    }

    // start-line, ex: HTTP/1.1 200 OK
    NSString *statusLine = [NKHTTPHelper scanUpToString:@"\r\n"
                                             fromString:rawHTTPHeader];
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
    rawHTTPHeader = [rawHTTPHeader substringFromIndex:statusLine.length];
    NSArray *headerFields = [[NKHTTPHelper scanUpToString:@"\r\n\r\n"
                                               fromString:rawHTTPHeader]
                             componentsSeparatedByString:@"\r\n"];
    NSLog(@"header-fields: %@", headerFields);

    NSMutableDictionary *tempHeaderFields = [[NSMutableDictionary alloc] init];
    for (NSString *headerField in headerFields) {
        NSString *fieldName = [NKHTTPHelper scanUpToString:@":"
                                                fromString:headerField];

            // Add 1 to remove previous colon.
        NSString *fieldValue = [headerField substringFromIndex:fieldName.length + 1];

            // remove leading and trailing OWS in field value.
        fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([fieldName isEqualToString:@"Set-Cookie"])
            continue;
        [tempHeaderFields setValue:fieldValue forKey:fieldName];
    }
    self.headerFields = [tempHeaderFields mutableCopy];

    _parsedHeader = YES;
    return YES;
}

- (NSUInteger)contentLength {
    id value = [self.headerFields valueForKey:@"Content-Length"];
    return value ? [value integerValue] : 0;
}

@end
