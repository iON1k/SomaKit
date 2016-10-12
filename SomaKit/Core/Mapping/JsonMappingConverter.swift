//
//  JsonMappingConverter.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

open class JsonMappingConverter<TValue: JsnonCovertible>: ConverterType {
    public typealias Type1 = TValue
    public typealias Type2 = String
    
    open func convertValue(_ value: Type1) throws -> Type2 {
        return try TValue.convertToJson(value)
    }
    
    open func convertValue(_ value: Type2) throws -> Type1 {
        return try TValue.convertToObject(value)
    }
}
