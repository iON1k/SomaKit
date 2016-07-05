//
//  SomaFunc.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public final class SomaFunc {
    public static func emptyFunc() {
        //Nothing
    }
    
    public static func emptyTransform<TValue>(value: TValue) -> TValue {
        return value
    }
    
    public static func truePredicate<TValue>(value: TValue) -> Bool {
        return true
    }
    
    public static func falsePredicate<TValue>(value: TValue) -> Bool {
        return false
    }
    
    public static func valuePredicate(value: Bool) -> Bool {
        return value
    }
    
    public static func negativePredicate(value: Bool) -> Bool {
        return !value
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