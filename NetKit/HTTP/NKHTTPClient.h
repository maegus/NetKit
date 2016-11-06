//
//  NKHTTPClient.h
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NKHTTPRequest;

@interface NKHTTPClient : NSObject

- (NKHTTPClient *(^)(NKHTTPRequest *request))newCall;

@end
