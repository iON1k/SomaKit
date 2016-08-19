//
//  DefaultValueType.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol _DefaultValueType {
    static var _defaultValue: Any { get }
}

extension _DefaultValueType where Self: DefaultValueType {
    public static var _defaultValue: Any {
        return defaultValue
    }
}

public protocol DefaultValueType: _DefaultValueType {
    static var defaultValue: Self { get }
}

extension Optional: DefaultValueType {
    public static var defaultValue: Optional {
        return nil
    }
}