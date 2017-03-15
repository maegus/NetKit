//
//  URLConvertable.swift
//  NetKit
//
//  Created by Draveness on 15/03/2017.
//  Copyright © 2017 Draveness. All rights reserved.
//

import Foundation

protocol URLConvertable { var toURL: URL { get } }
extension String: URLConvertable { var toURL: URL { get { return URL(string: self)! } } }
extension URL: URLConvertable { var toURL: URL { get { return self } } }
