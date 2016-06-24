//
//  ConverterType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ConverterType {
    associatedtype FromValueType
    associatedtype ToValueType
    
    func convertValue(value: FromValueType) throws -> ToValueType
    func convertValue(value: ToValueType) throws -> FromValueType
}
