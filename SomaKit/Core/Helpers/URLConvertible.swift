//
//  URLConvertible.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol URLConvertible {
    var url: URL? { get }
}

extension String: URLConvertible {
    public var url: URL? {
        return URL(string: self)
    }
}

extension URL: URLConvertible {
    public var url: URL? {
        return self
    }
}
