//
//  SameTypeConverter.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class SameTypeConverter<TValue>: ConverterType {
    public typealias Type1 = TValue
    public typealias Type2 = TValue
    
    public func convertValue(_ value: Type1) throws -> Type2 {
        return value
    }
}
