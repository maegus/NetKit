//
//  NKHTTPResponse.h
//  NetKit
//
//  Created by Draveness on 12/7/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKHTTPResponse : NSObject

- (BOOL)appendData:(NSData *)data;

@property (nonatomic, assign, readonly) NSUInteger statusCode;
@property (nonatomic, strong, readonly) NSString *reasonPhrase;

@property (nonatomic, strong, readonly) NSDictionary *headerFields;
@property (nonatomic, strong, readonly) NSData *body;

@end
