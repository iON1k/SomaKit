//
//  StringCachingKeyProvider.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public typealias StringCachingKeyProvider = _StringCachingKeyProvider & CachingKeyProvider

public protocol _StringCachingKeyProvider {
    var stringCachingKey: String { get }
}

extension _StringCachingKeyProvider where Self: CachingKeyProvider {
    public typealias CachingKeyType = String
    
    public var cachingKey: String {
        return stringCachingKey
    }
}
