//
//  StringKeyConvertible.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StringKeyConvertible {
    var stringKey: String { get }
}

extension StringKeyConvertible {
    public var stringKey: String {
        return String(describing: self)
    }
}

extension String: StringKeyConvertible {
    public var stringKey: String {
        return self
    }
}

extension URL: StringKeyConvertible {
    public var stringKey: String {
        return absoluteString
    }
}

extension Int: StringKeyConvertible {
    //Nothing
}

extension Int8: StringKeyConvertible {
    //Nothing
}

extension Int16: StringKeyConvertible {
    //Nothing
}

extension Int32: StringKeyConvertible {
    //Nothing
}

extension Int64: StringKeyConvertible {
    //Nothing
}

extension UInt: StringKeyConvertible {
    //Nothing
}

extension UInt8: StringKeyConvertible {
    //Nothing
}

extension UInt16: StringKeyConvertible {
    //Nothing
}

extension UInt32: StringKeyConvertible {
    //Nothing
}

extension UInt64: StringKeyConvertible {
    //Nothing
}

extension Double: StringKeyConvertible {
    //Nothing
}

extension Float: StringKeyConvertible {
    //Nothing
}

extension Bool: StringKeyConvertible {
    //Nothing
}

extension Character: StringKeyConvertible {
    //Nothing
}

extension UnicodeScalar: StringKeyConvertible {
    //Nothing
}

extension Array: StringKeyConvertible {
    public var stringKey: String {
        var resultString = ""
        
        for element in self {
            guard let cachingKeyElement = element as? StringKeyConvertible else {
                Debug.fatalError("Array has not implemented StringKeyConvertible element \(type(of: element))")
            }
            
            resultString += cachingKeyElement.stringKey
        }
        
        return resultString
    }
}

extension Dictionary: StringKeyConvertible {
    public var stringKey: String {
        var resultString = ""
        
        for (key, value) in self {
            guard let cachingKeyKey = key as? StringKeyConvertible else {
                Debug.fatalError("Dictionary has not implemented StringKeyConvertible key \(type(of: key))")
            }
            
            guard let cachingKeyValue = value as? StringKeyConvertible else {
                Debug.fatalError("Dictionary has not implemented StringKeyConvertible element \(type(of: value))")
            }
            
            resultString += cachingKeyKey.stringKey + cachingKeyValue.stringKey
        }
        
        return resultString
    }
}

extension NSString: StringKeyConvertible {
    public var stringKey: String {
        return self as String
    }
}

extension CGFloat: StringKeyConvertible {
    public var stringKey: String {
        return String(describing: self)
    }
}

extension NSNumber: StringKeyConvertible {
    public var stringKey: String {
        return stringValue
    }
}
