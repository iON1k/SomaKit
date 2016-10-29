//
//  AnyConverter.swift
//  SomaKit
//
//  Created by Anton on 24.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

open class AnyConverter<TValue1, TValue2>: ConverterType {
    public typealias Type1 = TValue1
    public typealias Type2 = TValue2
    
    public typealias ConverterHandler1Type = (Type1) throws -> Type2
    public typealias ConverterHandler2Type = (Type2) throws -> Type1
    
    private let converterHandler1: ConverterHandler1Type
    private let converterHandler2: ConverterHandler2Type
    
    open func convertValue(_ value: Type1) throws -> Type2 {
        return try converterHandler1(value)
    }
    
    open func convertValue(_ value: Type2) throws -> Type1 {
        return try converterHandler2(value)
    }
    
    public init(_ converterHandler1: @escaping ConverterHandler1Type, _ converterHandler2: @escaping ConverterHandler2Type) {
        self.converterHandler1 = converterHandler1
        self.converterHandler2 = converterHandler2
    }
}

extension AnyConverter {
    public func asConverter() -> AnyConverter<Type1, Type2> {
        return self
    }
}
