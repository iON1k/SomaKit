//
//  AnyObjectConvertiableType.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol AnyObjectConvertiableType {
    func asAnyObject() -> AnyObject
}

extension AnyObjectConvertiableType where Self: AnyObject {
    public func asAnyObject() -> AnyObject {
        return self
    }
}

extension Int: AnyObjectConvertiableType {
    public func asAnyObject() -> AnyObject {
        return self
    }
}

extension UInt: AnyObjectConvertiableType {
    public func asAnyObject() -> AnyObject {
        return self
    }
}

extension Float: AnyObjectConvertiableType {
    public func asAnyObject() -> AnyObject {
        return self
    }
}

extension String: AnyObjectConvertiableType {
    public func asAnyObject() -> AnyObject {
        return self
    }
}

extension Bool: AnyObjectConvertiableType {
    public func asAnyObject() -> AnyObject {
        return self
    }
}