//
//  NKSocketStream.h
//  NetKit
//
//  Created by Draveness on 11/6/16.
//  Copyright © 2016 Draveness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKHTTPRequest.h"

@interface NKSocketStream : NSObject

+ (void)sendRequest:(NKHTTPRequest *)request
         completion:(void(^)(NSData *))completion;

@end
