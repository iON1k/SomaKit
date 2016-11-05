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
    public static func typeName(_ classType: Any.Type) -> String {
        return String(describing: classType)
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
    public static func safe(_ body: (Void) throws -> Void) {
        do {
            try body()
        } catch let error {
            Log.error(error)
        }
    }
    
    public static func safe<TResult>(_ body: (Void) throws -> TResult?) -> TResult? {
        do {
            return try body()
        } catch let error {
            Log.error(error)
        }
        
        return nil
    }
    
    public static func safe<TResult>(_ defaultResult: TResult, body: (Void) throws -> TResult) -> TResult {
        do {
            return try body()
        } catch let error {
            Log.error(error)
        }
        
        return defaultResult
    }
}
