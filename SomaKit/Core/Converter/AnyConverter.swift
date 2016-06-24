//
//  AnyConverter.swift
//  SomaKit
//
//  Created by Anton on 24.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class AnyConverter<TValue1, TValue2>: ConverterType {
    public typealias FirstType = TValue1
    public typealias SecondType = TValue2
    
    private let sourceConvertValue1: FirstType throws -> SecondType
    private let sourceConvertValue2: SecondType throws -> FirstType
    
    public func convertValue(value: FirstType) throws -> SecondType {
        return try sourceConvertValue1(value)
    }
    
    public func convertValue(value: SecondType) throws -> FirstType {
        return try sourceConvertValue2(value)
    }
    
    public init<TConverter: ConverterType where TConverter.FirstType == FirstType,
        TConverter.SecondType == SecondType>(sourceConverter: TConverter) {
        sourceConvertValue1 = sourceConverter.convertValue
        sourceConvertValue2 = sourceConverter.convertValue
    }
}

extension ConverterType {
    public func asAny() -> AnyConverter<FirstType, SecondType> {
        return AnyConverter(sourceConverter: self)
    }
}