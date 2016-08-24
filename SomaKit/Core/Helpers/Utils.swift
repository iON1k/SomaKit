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
}

extension Utils {
    public static func typeName(classType: Any.Type) -> String {
        return String(classType)
    }
    
    public static func sameTypes(first: Any, second: Any) -> Bool {
        return first.dynamicType == second.dynamicType
    }
}

extension Utils {
    public static func unsafeCast<T>(sourceValue: Any) -> T {
        guard let castedValue = sourceValue as? T else {
            Debug.fatalError("Failing unsafe casting value with type \(T.self) to type \(sourceValue.dynamicType)")
        }
        
        return castedValue
    }
}

extension Utils {
    public static func ensureIsMainThread() {
        guard NSThread.isMainThread() else {
            Debug.fatalError("Is not main thread")
        }
    }
}

extension Utils {
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

extension Utils {
    public static func safe(body: Void throws -> Void) {
        do {
            try body()
        } catch let error {
            Log.log(error)
        }
    }
    
    public static func safe<TResult>(body: Void throws -> TResult?) -> TResult? {
        do {
            return try body()
        } catch let error {
            Log.log(error)
        }
        
        return nil
    }
    
    public static func safe<TResult>(defaultResult: TResult, body: Void throws -> TResult) -> TResult {
        do {
            return try body()
        } catch let error {
            Log.log(error)
        }
        
        return defaultResult
    }
}