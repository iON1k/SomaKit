//
//  Equivalentable.swift
//  SomaKit
//
//  Created by Anton on 06.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol Equivalentable {
    func isEquivalent(other: Any) -> Bool
}

extension Equivalentable where Self: Equatable  {
    public func isEquivalent(other: Any) -> Bool {
        guard let castedOther = other as? Self else {
            return false
        }
        
        return self == castedOther
    }
}