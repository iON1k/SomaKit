//
//  CachingKeyProvider.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol CachingKeyProvider {
    associatedtype CachingKeyType
    var cachingKey: CachingKeyType { get }
}
