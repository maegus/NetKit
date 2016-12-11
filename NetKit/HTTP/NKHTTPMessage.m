//
//  NKHTTPMessage.m
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import "NKHTTPMessage.h"

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

@interface NKHTTPMessage ()

@property (nonatomic, copy) NSMutableString *plainMessage;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSString *reasonMessage;

@property (nonatomic, strong) NSString *rawHTTPHeader;

@end

@implementation NKHTTPMessage

- (instancetype)init {
    if (self = [super init]) {
        _plainMessage = [[NSMutableString alloc] init];
        _index = 0;
    }
    return self;
}

- (void)appendMessage:(NSString *)message {
    [self.plainMessage appendString:message];

    if (self.rawHTTPHeader) {
        [self parseHTTPHeader];
    }
}

- (void)parseHTTPHeader {
    NSString *rawHTTPHeader = [self.rawHTTPHeader copy];

    // start-line, ex: HTTP/1.1 200 OK
    NSString *startLine = [NKHTTPHelper scanUpToString:@"\r\n" fromString:rawHTTPHeader];
    NSLog(@"start-line: %@", startLine);

    // header-field
    rawHTTPHeader = [rawHTTPHeader substringFromIndex:startLine.length];
    NSArray *headerFields = [[NKHTTPHelper scanUpToString:@"\r\n\r\n" fromString:rawHTTPHeader] componentsSeparatedByString:@"\r\n"];
    NSLog(@"header-fields: %@", headerFields);

    for (NSString *headerField in headerFields) {
        NSString *fieldName = [NKHTTPHelper scanUpToString:@":" fromString:headerField];

        // Add 1 to remove previous colon.
        NSString *fieldValue = [headerField substringFromIndex:fieldName.length + 1];

        // remove leading and trailing OWS in field value.
        fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"field-name:\t%@", fieldName);
        NSLog(@"field-value:\t%@", fieldValue);
    }
}

- (NSString *)nextLine {
    NSInteger endIndex = self.plainMessage.length - 1;
    NSInteger length = endIndex - self.index;
    length = (length >= 0) ? length : 0;
    NSString *scannedString = [self.plainMessage substringWithRange:NSMakeRange(self.index, length)];

    NSString *result = nil;
    NSScanner *scanner = [[NSScanner alloc] initWithString:scannedString];
    [scanner scanUpToString:@"\r\n" intoString:&result];
    NSLog(@"%@", result);
    self.index += result.length;
    return result;
}

- (NSString *)rawHTTPHeader {
    if (!_rawHTTPHeader) {
        _rawHTTPHeader = [NKHTTPHelper httpHeader:self.plainMessage];
    }
    return _rawHTTPHeader;
}

@end
