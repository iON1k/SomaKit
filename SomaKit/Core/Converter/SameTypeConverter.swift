//
//  SameTypeConverter.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class SameTypeConverter<TValue>: ConverterType {
    public typealias FirstType = TValue
    public typealias SecondType = TValue
    
    public func convertValue(value: FirstType) throws -> SecondType {
        return value
    }
}
