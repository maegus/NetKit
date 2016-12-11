//
//  NKHTTPMessage.m
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import "NKHTTPMessage.h"

@interface NKHTTPMessage ()

@property (nonatomic, copy) NSMutableString *plainMessage;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSString *reasonMessage;

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
    [self nextLine];
    [self nextLine];
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

@end
