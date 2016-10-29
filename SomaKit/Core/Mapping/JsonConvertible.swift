//
//  JsonCovertible.swift
//  SomaKit
//
//  Created by Anton on 23.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol _JsonCovertible {
    static func _convertToJson(_ object: Any) throws -> String
    static func _convertToObject(_ json: String) throws -> Any
}

public extension _JsonCovertible {
    public func convertToJson() throws -> String {
        return try Self._convertToJson(self)
    }
}

public extension _JsonCovertible where Self: JsonCovertible {
    public static func _convertToJson(_ object: Any) throws -> String {
        guard let castedObject = object as? Self else {
            throw SomaError("Converting to json wrong type \(type(of: (object)))")
        }
        
        return try convertToJson(castedObject)
    }
    
    public static func _convertToObject(_ json: String) throws -> Any {
        return try convertToObject(json)
    }
}

public protocol JsonCovertible: _JsonCovertible {
    static func convertToJson(_ object: Self) throws -> String
    static func convertToObject(_ json: String) throws -> Self
}
