//
//  OptionalType.swift
//  SomaKit
//
//  Created by Anton on 22.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//


public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped { get }
    var hasValue: Bool { get }
}

extension Optional: OptionalType {
    public var value: Wrapped {
        return self!
    }
    
    public var hasValue: Bool {
        return self != nil
    }
}