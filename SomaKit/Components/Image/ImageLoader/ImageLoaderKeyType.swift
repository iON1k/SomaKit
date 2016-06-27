//
//  ImageLoaderKeyType.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ImageLoaderKeyType {
    var imageLoaderCacheKey: String { get }
}

extension String: ImageLoaderKeyType {
    public var imageLoaderCacheKey: String {
        return self
    }
}
