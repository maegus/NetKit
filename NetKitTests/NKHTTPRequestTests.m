//
//  NKHTTPRequestTests.m
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NKHTTPRequest.h"
#import "NKHTTPClient.h"

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
    NKHTTPRequest *request = [[NKHTTPRequest alloc] initWithURL:@"http://www.tictalkin.com/"];

    NKHTTPClient *client = [[NKHTTPClient alloc] init];
    client.newCall(request);

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
