//
//  StringKeyConvertiable.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol StringKeyConvertiable {
    func asStringKey() -> String
}

extension String: StringKeyConvertiable {
    public func asStringKey() -> String {
        return self
    }
}

extension Int: StringKeyConvertiable {
    public func asStringKey() -> String {
        return String(self)
    }
}

extension UInt: StringKeyConvertiable {
    public func asStringKey() -> String {
        return String(self)
    }
}

extension Double: StringKeyConvertiable {
    public func asStringKey() -> String {
        return String(self)
    }
}

extension Float: StringKeyConvertiable {
    public func asStringKey() -> String {
        return String(self)
    }
}