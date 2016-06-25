//
//  JSONMappingConverter.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

public class JSONMappingConverter<TValue: Mappable>: ConverterType {
    public typealias Type1 = TValue
    public typealias Type2 = String
    
    private let mapper = Mapper<Type1>()
    
    public func convertValue(value: Type1) throws -> Type2 {
        let mappingResult = mapper.toJSONString(value)
        
        guard let result = mappingResult else {
            throw SomaError("Model \(value.dynamicType) mapping to JSON error")
        }
        
        return result
    }
    
    public func convertValue(value: Type2) throws -> Type1 {
        let mappingResult = mapper.map(value)
        
        guard let result = mappingResult else {
            throw SomaError("JSON mapping to model error\n\(value)")
        }
        
        return result
    }
}
