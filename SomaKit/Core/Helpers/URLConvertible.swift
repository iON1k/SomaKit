//
//  URLConvertible.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol URLConvertible {
    var url: NSURL? { get }
}

extension String: URLConvertible {
    public var url: NSURL? {
        return NSURL(string: self)
    }
}

extension NSURL: URLConvertible {
    public var url: NSURL? {
        return self
    }
}