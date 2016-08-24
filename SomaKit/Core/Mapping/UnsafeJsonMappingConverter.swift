//
//  UnsafeJsonMappingConverter.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

public class UnsafeJsonMappingConverter<TValue>: ConverterType {
    public typealias Type1 = TValue
    public typealias Type2 = String
    
    public func convertValue(value: Type1) throws -> Type2 {
        return try castToJsnonCovertibleType(Type1)._convertToJson(value)
    }
    
    public func convertValue(value: Type2) throws -> Type1 {
        let resultObject = try castToJsnonCovertibleType(Type1)._convertToObject(value)
        
        guard let result = resultObject as? Type1 else {
            throw SomaError("JsonMappingConverter wrong mapping type \(resultObject.dynamicType)")
        }
        
        return result
    }
    
    private func castToJsnonCovertibleType<TValue>(type: TValue.Type) throws -> _JsnonCovertible.Type {
        guard let jsonConvertibleType = Type1.self as? _JsnonCovertible.Type else {
            throw SomaError("Type \(Type1.self) doesn't conform to protocol _JsnonCovertible")
        }
        
        return jsonConvertibleType
    }
}