//
//  NKHTTPRequestTests.m
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NKHTTPRequest.h"
#import "NKSocketStream.h"

@interface NKHTTPRequestTests : XCTestCase

@end

@implementation NKHTTPRequestTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    XCTestExpectation *exception = [self expectationWithDescription:@"testExample"];
    NKHTTPRequest *request = [[NKHTTPRequest alloc] initWithURL:@"http://www.baidu.com/index.html"];

    [NKSocketStream sendRequest:request
                     completion:^(NSData *data) {
                         [exception fulfill];
                     }];
    NSLog(@"%@", request.rawValue);

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
