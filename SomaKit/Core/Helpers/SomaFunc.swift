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
    
    public static func emptyFunc<TValue>(value: TValue) {
        //Nothing
    }
    
    public static func sameTransform<TValue>(value: TValue) -> TValue {
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
    
    private init() {
        //Nothing
    }
}