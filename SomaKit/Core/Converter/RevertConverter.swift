//
//  RevertConverter.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class RevertConverter<TValue1, TValue2>: HandleConverter<TValue1, TValue2> {
    public init<TConverter: ConverterType where TConverter.Type1 == Type2,
        TConverter.Type2 == Type1>(sourceConverter: TConverter) {
        super.init(converterHandler1: sourceConverter.convertValue, converterHandler2: sourceConverter.convertValue)
    }
}

extension ConverterType {
    public func revert() -> RevertConverter<Type2, Type1> {
        return RevertConverter(sourceConverter: self)
    }
}