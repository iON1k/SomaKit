//
//  ConverterConvertibleType.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ConverterConvertibleType {
    associatedtype Type1
    associatedtype Type2
    
    func asConverter() -> AnyConverter<Type1, Type2>
}
