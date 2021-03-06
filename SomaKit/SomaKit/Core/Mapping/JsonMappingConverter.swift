//
//  JsonMappingConverter.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

public class JsonMappingConverter<TValue: JsonStringConvertible>: ConverterType {
    public typealias Type1 = TValue
    public typealias Type2 = String
    
    public func convertValue(_ value: Type1) throws -> Type2 {
        return try TValue.convertToJson(value)
    }
    
    public func convertValue(_ value: Type2) throws -> Type1 {
        return try TValue.convertToObject(value)
    }
}
