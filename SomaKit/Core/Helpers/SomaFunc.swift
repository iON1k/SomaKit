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
    
    private init() {
        //Nothing
    }
}