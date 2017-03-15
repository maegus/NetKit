//
//  NKHTTPRequest.swift
//  NetKit
//
//  Created by Draveness on 15/03/2017.
//  Copyright © 2017 Draveness. All rights reserved.
//

import Foundation

struct NKHTTPRequest {
    
    enum HTTPMethod: String {
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    let method: HTTPMethod = .get
    let url: URL
    let host: String
    let port: Int
    let version: String = "1.1"
    var headers: [String: String] = [:]
    
    init(url: URLConvertable) {
        self.url = url.toURL
        self.port = self.url.port ?? 80
        self.host = self.url.host!
        self.headers["Host"] = self.host
    }
}

