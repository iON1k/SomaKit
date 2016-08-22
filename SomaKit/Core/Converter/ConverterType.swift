//
//  ConverterType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ConverterType: ConverterConvertibleType {
    associatedtype Type1
    associatedtype Type2
    
    func convertValue(value: Type1) throws -> Type2
    func convertValue(value: Type2) throws -> Type1
}

extension ConverterType {
    public func asConverter() -> AnyConverter<Type1, Type2> {
        return AnyConverter(convertValue, convertValue)
    }
    
    public func revert() -> AnyConverter<Type2, Type1> {
        return AnyConverter(convertValue, convertValue)
    }
}