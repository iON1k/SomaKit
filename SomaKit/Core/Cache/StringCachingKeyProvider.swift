//
//  StringCachingKeyProvider.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StringCachingKeyProvider: CachingKeyProvider {
    var stringCachingKey: String { get }
}

extension StringCachingKeyProvider {
    public typealias CachingKeyType = String
    
    public var cachingKey: String {
        return stringCachingKey
    }
}
