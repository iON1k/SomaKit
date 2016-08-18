//
//  OptionalType.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//


public protocol OptionalType {
    var hasValue: Bool { get }
}

public protocol OptionalValueType: OptionalType {
    associatedtype Wrapped
    var value: Wrapped { get }
}

extension Optional: OptionalValueType {
    public var value: Wrapped {
        return self!
    }
    
    public var hasValue: Bool {
        return self != nil
    }
}