//
//  JsnonCovertible.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol _JsnonCovertible {
    static func _convertToJson(object: Any) throws -> String
    static func _convertToObject(json: String) throws -> Any
}

public extension _JsnonCovertible {
    public func convertToJson() throws -> String {
        return try Self._convertToJson(self)
    }
}

public extension _JsnonCovertible where Self: JsnonCovertible {
    public static func _convertToJson(object: Any) throws -> String {
        guard let castedObject = object as? Self else {
            throw SomaError("Converting to json wrong type \(object.dynamicType)")
        }
        
        return try convertToJson(castedObject)
    }
    
    public static func _convertToObject(json: String) throws -> Any {
        return try convertToObject(json)
    }
}

public protocol JsnonCovertible {
    static func convertToJson(object: Self) throws -> String
    static func convertToObject(json: String) throws -> Self
}
