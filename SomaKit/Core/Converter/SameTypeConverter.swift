//
//  SameTypeConverter.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class SameTypeConverter<TValue>: ConverterType {
    public typealias Type1 = TValue
    public typealias Type2 = TValue
    
    open func convertValue(_ value: Type1) throws -> Type2 {
        return value
    }
}
