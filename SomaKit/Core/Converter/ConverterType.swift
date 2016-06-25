//
//  ConverterType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ConverterType {
    associatedtype Type1
    associatedtype Type2
    
    func convertValue(value: Type1) throws -> Type2
    func convertValue(value: Type2) throws -> Type1
}
