//
//  CacheValue.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public typealias CacheTimeType = Double

public class CacheValue<TData> {
    public let data: TData
    public let creationTime: CacheTimeType
    
    public init(data: TData, creationTime: CacheTimeType) {
        self.data = data
        self.creationTime = creationTime
    }
}
