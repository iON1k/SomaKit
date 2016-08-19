//
//  OptionalType.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//


public protocol _OptionalType {
    var _value: Any { get }
    var hasValue: Bool { get }
}

extension _OptionalType where Self: OptionalType {
    public var _value: Any {
        return value
    }
}

public protocol OptionalType: _OptionalType {
    associatedtype Wrapped
    var value: Wrapped { get }
}

extension Optional: OptionalType {
    public var value: Wrapped {
        return self!
    }
    
    public var hasValue: Bool {
        return self != nil
    }
}