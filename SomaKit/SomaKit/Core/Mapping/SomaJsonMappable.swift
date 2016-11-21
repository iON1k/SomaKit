//
//  SomaJsonMappable.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import ObjectMapper

public protocol SomaJsonMappable: Mappable, JsonStringConvertible {
    //Nothing
}

extension SomaJsonMappable {
    public static func convertToJson(_ object: Self) throws -> String {
        let mappingResult = Mapper().toJSONString(object)
        
        guard let result = mappingResult else {
            throw SomaError("Model \(self) mapping to JSON error")
        }
        
        return result
    }
    
    public static func convertToObject(_ json: String) throws -> Self {
        let mappingResult: Self? = Mapper().map(JSONString: json)
        
        guard let result = mappingResult else {
            throw SomaError("JSON mapping to model error\n\(json)")
        }
        
        return result
    }
}
