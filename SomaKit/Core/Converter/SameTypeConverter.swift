//
//  SameTypeConverter.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class SameTypeConverter<TValue>: ConverterType {
    public typealias FromValueType = TValue
    public typealias ToValueType = TValue
    
    public func convertValue(value: FromValueType) throws -> ToValueType {
        return value
    }
}
