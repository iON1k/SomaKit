//
//  Utils.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public final class Utils {
    private init() {
        //Nothing
    }
}

extension Utils {
    @noreturn public static func abstractMethod(methodName: String = "Method") {
        Debug.fatalError("\(methodName) has not been implemented")
    }
    
    public static func typeName(classType: Any.Type) -> String {
        return String(classType)
    }
    
    public static func ensureIsMainThread() {
        guard NSThread.isMainThread() else {
            Debug.fatalError("Is not main thread")
        }
    }
    
    public static func unsafeCast<T>(sourceValue: Any) -> T {
        if let castedValue = sourceValue as? T {
            return castedValue
        }
        
        Debug.fatalError("Failing unsafe casting value with type \(T.self) to type \(sourceValue.dynamicType)")
    }
    
    public static func sameTypes(first: Any, second: Any) -> Bool {
        return first.dynamicType == second.dynamicType
    }
    
    public static func isEquivalentValues<TValue>(value1: TValue, value2: TValue) -> Bool {
        if let optionalValue1 = value1 as? _OptionalType, optionalValue2 = value2 as? _OptionalType {
            let hasValue1 = optionalValue1.hasValue
            let hasValue2 = optionalValue2.hasValue
            guard hasValue1 && hasValue2 else {
                return !hasValue1 && !hasValue2
            }
        }
        
        if let value1Object = value1 as? AnyObject, value2Object = value2 as? AnyObject {
            guard value1Object !== value2Object else {
                return true
            }
        }
        
        guard let equivalentableValue1 = value1 as? _Equivalentable else {
            return false
        }
        
        return equivalentableValue1.isEquivalent(value2)
    }
}