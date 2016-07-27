//
//  Utils.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public final class Utils {
    @noreturn public static func abstractMethod(methodName: String = "Method") {
        fatalError("\(methodName) has not been implemented")
    }
    
    public static func typeName(classType: Any.Type) -> String {
        return String(classType)
    }
    
    public static func ensureIsMainThread() {
        guard NSThread.isMainThread() else {
            fatalError("Is not main thread")
        }
    }
    
    public static func unsafeCast<T, E>(sourceValue: T) -> E {
        if let castedValue = sourceValue as? E {
            return castedValue
        }
        
        fatalError("Failing unsafe casting value with type \(T.self) to type \(E.self)")
    }
    
    private init() {
        //Nothing
    }
}