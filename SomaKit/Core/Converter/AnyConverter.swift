//
//  AnyConverter.swift
//  SomaKit
//
//  Created by Anton on 24.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class AnyConverter<TValue1, TValue2>: HandleConverter<TValue1, TValue2> {
    public init<TConverter: ConverterType where TConverter.Type1 == Type1,
        TConverter.Type2 == Type2>(sourceConverter: TConverter) {
        super.init(converterHandler1: sourceConverter.convertValue, converterHandler2: sourceConverter.convertValue)
    }
}

extension ConverterType {
    public func asAny() -> AnyConverter<Type1, Type2> {
        return AnyConverter(sourceConverter: self)
    }
}