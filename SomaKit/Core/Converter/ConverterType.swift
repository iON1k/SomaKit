//
//  ConverterType.swift
//  SomaKit
//
//  Created by Anton on 23.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ConverterType {
    associatedtype FirstType
    associatedtype SecondType
    
    func convertValue(value: FirstType) throws -> SecondType
    func convertValue(value: SecondType) throws -> FirstType
}
