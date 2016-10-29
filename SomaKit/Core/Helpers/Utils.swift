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
    public static func abstractMethod(_ methodName: String = "Method") -> Never  {
        Debug.fatalError("\(methodName) has not been implemented")
    }
}

extension Utils {
    public static func typeName(_ classType: Any.Type) -> String {
        return String(describing: classType)
    }
    
    public static func sameTypes(_ first: Any, second: Any) -> Bool {
        return type(of: first) == type(of: second)
    }
}

extension Utils {
    public static func unsafeCast<T>(_ sourceValue: Any) -> T {
        guard let castedValue = sourceValue as? T else {
            Debug.fatalError("Failing unsafe casting value with type \(T.self) to type \(type(of: sourceValue))")
        }
        
        return castedValue
    }
}

extension Utils {
    public static func ensureIsMainThread() {
        guard Thread.isMainThread else {
            Debug.fatalError("Is not main thread")
        }
    }
}

extension Utils {
    public static func safe(_ body: (Void) throws -> Void) {
        do {
            try body()
        } catch let error {
            Log.log(error)
        }
    }
    
    public static func safe<TResult>(_ body: (Void) throws -> TResult?) -> TResult? {
        do {
            return try body()
        } catch let error {
            Log.log(error)
        }
        
        return nil
    }
    
    public static func safe<TResult>(_ defaultResult: TResult, body: (Void) throws -> TResult) -> TResult {
        do {
            return try body()
        } catch let error {
            Log.log(error)
        }
        
        return defaultResult
    }
}
