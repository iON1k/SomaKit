//
//  Utils.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

@noreturn public func abstractMethod(methodName: String = "Method") {
    fatalError("\(methodName) has not been implemented")
}

func typeName(classType: Any.Type) -> String {
    return String(classType)
}