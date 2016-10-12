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
    
    public static func emptyFunc(_ value: Any) {
        //Nothing
    }
    
    public static func sameTransform<TValue>(_ value: TValue) -> TValue {
        return value
    }
    
    public static func truePredicate(_ value: Any) -> Bool {
        return true
    }
    
    public static func falsePredicate(_ value: Any) -> Bool {
        return false
    }
    
    public static func valuePredicate(_ value: Bool) -> Bool {
        return value
    }
    
    public static func negativePredicate(_ value: Bool) -> Bool {
        return !value
    }
    
    public static func justNil<TValue>() -> TValue? {
        return nil
    }
    
    fileprivate init() {
        //Nothing
    }
}
