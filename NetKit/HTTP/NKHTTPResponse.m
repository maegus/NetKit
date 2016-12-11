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

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSString *reasonMessage;

@property (nonatomic, strong) NSString *rawHTTPHeader;

@property (nonatomic, strong) NSDictionary *headerFields;

@end

@implementation NKHTTPResponse

- (instancetype)init {
    if (self = [super init]) {
        _plainMessage = [[NSMutableString alloc] init];
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
    NSString *statusLine = [NKHTTPHelper scanUpToString:@"\r\n" fromString:rawHTTPHeader];
    NSLog(@"status-line: %@", statusLine);

    // header-field
    rawHTTPHeader = [rawHTTPHeader substringFromIndex:statusLine.length];
    NSArray *headerFields = [[NKHTTPHelper scanUpToString:@"\r\n\r\n" fromString:rawHTTPHeader] componentsSeparatedByString:@"\r\n"];
    NSLog(@"header-fields: %@", headerFields);

    for (NSString *headerField in headerFields) {
        NSString *fieldName = [NKHTTPHelper scanUpToString:@":" fromString:headerField];

            // Add 1 to remove previous colon.
        NSString *fieldValue = [headerField substringFromIndex:fieldName.length + 1];

            // remove leading and trailing OWS in field value.
        fieldValue = [fieldValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([fieldName isEqualToString:@"Set-Cookie"])
            continue;

        NSLog(@"%@:\t%@", fieldName, fieldValue);
    }
}

- (NSString *)rawHTTPHeader {
    if (!_rawHTTPHeader) {
        _rawHTTPHeader = [NKHTTPHelper httpHeader:self.plainMessage];
    }
    return _rawHTTPHeader;
}

@end
