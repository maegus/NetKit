//
//  NKHTTPRequest.h
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NKHTTPRequestMethod) {
    NKHTTPRequestMethodGET,
    NKHTTPRequestMethodPOST,
    NKHTTPRequestMethodPUT,
};

@interface NKHTTPRequest : NSObject

@property (nonatomic, strong) NSString *method;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSData *body;

@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic, strong, readonly) NSString *host;

@property (nonatomic, strong, readonly) NSString *resource;

@end

NS_ASSUME_NONNULL_END
