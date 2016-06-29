//
//  StringKeyConvertiable.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StringKeyConvertiable {
    var stringKey: String { get }
}

extension StringKeyConvertiable {
    public var stringKey: String {
        return String(self)
    }
}

extension String: StringKeyConvertiable {
    public var stringKey: String {
        return self
    }
}

extension Int: StringKeyConvertiable {
    //Nothing
}

extension Int8: StringKeyConvertiable {
    //Nothing
}

extension Int16: StringKeyConvertiable {
    //Nothing
}

extension Int32: StringKeyConvertiable {
    //Nothing
}

extension Int64: StringKeyConvertiable {
    //Nothing
}

extension UInt: StringKeyConvertiable {
    //Nothing
}

extension UInt8: StringKeyConvertiable {
    //Nothing
}

extension UInt16: StringKeyConvertiable {
    //Nothing
}

extension UInt32: StringKeyConvertiable {
    //Nothing
}

extension UInt64: StringKeyConvertiable {
    //Nothing
}

extension Double: StringKeyConvertiable {
    //Nothing
}

extension Float: StringKeyConvertiable {
    //Nothing
}

extension Bool: StringKeyConvertiable {
    //Nothing
}

extension Character: StringKeyConvertiable {
    //Nothing
}

extension UnicodeScalar: StringKeyConvertiable {
    //Nothing
}

extension Array: StringKeyConvertiable {
    public var stringKey: String {
        var resultString = ""
        
        for element in self {
            guard let cachingKeyElement = element as? StringKeyConvertiable else {
                fatalError("Array has not implemented StringKeyConvertiable element \(element.dynamicType)")
            }
            
            resultString += cachingKeyElement.stringKey
        }
        
        return resultString
    }
}

extension Dictionary: StringKeyConvertiable {
    public var stringKey: String {
        var resultString = ""
        
        for (key, value) in self {
            guard let cachingKeyKey = key as? StringKeyConvertiable else {
                fatalError("Dictionary has not implemented StringKeyConvertiable key \(key.dynamicType)")
            }
            
            guard let cachingKeyValue = value as? StringKeyConvertiable else {
                fatalError("Dictionary has not implemented StringKeyConvertiable element \(value.dynamicType)")
            }
            
            resultString += cachingKeyKey.stringKey + cachingKeyValue.stringKey
        }
        
        return resultString
    }
}

extension NSString: StringKeyConvertiable {
    public var stringKey: String {
        return self as String
    }
}

extension CGFloat: StringKeyConvertiable {
    public var stringKey: String {
        return String(self)
    }
}

extension NSNumber: StringKeyConvertiable {
    public var stringKey: String {
        return stringValue
    }
}