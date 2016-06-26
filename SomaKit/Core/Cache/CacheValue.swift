//
//  CacheValue.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class CacheValue<TData> {
    public let data: TData
    public let creationTimestamp: Double
    
    public init(data: TData, creationTimestamp: Double) {
        self.data = data
        self.creationTimestamp = creationTimestamp
    }
}
