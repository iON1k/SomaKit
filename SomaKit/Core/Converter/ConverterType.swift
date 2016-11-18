//
//  ConverterType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ConverterType {
    associatedtype Type1
    associatedtype Type2
    
    func convertValue(_ value: Type1) throws -> Type2
    func convertValue(_ value: Type2) throws -> Type1
    
    func asConverter() -> Converter<Type1, Type2>
}

extension ConverterType {
    public func asConverter() -> Converter<Type1, Type2> {
        return Converter(convertValue, convertValue)
    }
    
    public func revert() -> Converter<Type2, Type1> {
        return Converter(convertValue, convertValue)
    }
}

public class Converter<TValue1, TValue2>: ConverterType {
    public typealias Type1 = TValue1
    public typealias Type2 = TValue2
    
    public typealias ConverterHandler1Type = (Type1) throws -> Type2
    public typealias ConverterHandler2Type = (Type2) throws -> Type1
    
    private let converterHandler1: ConverterHandler1Type
    private let converterHandler2: ConverterHandler2Type
    
    public func convertValue(_ value: Type1) throws -> Type2 {
        return try converterHandler1(value)
    }
    
    public func convertValue(_ value: Type2) throws -> Type1 {
        return try converterHandler2(value)
    }
    
    public func asConverter() -> Converter<Type1, Type2> {
        return self
    }
    
    public init(_ converterHandler1: @escaping ConverterHandler1Type, _ converterHandler2: @escaping ConverterHandler2Type) {
        self.converterHandler1 = converterHandler1
        self.converterHandler2 = converterHandler2
    }
}
