//
//  Equivalentable.swift
//  SomaKit
//
//  Created by Anton on 06.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol _Equivalentable {
    func isEquivalent(other: Any) -> Bool
}

extension _Equivalentable where Self: Equivalentable {
    public func isEquivalent(other: Any) -> Bool {
        guard let castedOhter = other as? Self else {
            return false
        }
        
        return isEquivalent(castedOhter)
    }
}

public protocol Equivalentable: _Equivalentable {
    func isEquivalent(other: Self) -> Bool
}

extension Equivalentable where Self: Equatable  {
    public func isEquivalent(other: Self) -> Bool {
        return self == other
    }
}