//
//  Collection+Extension.swift
//  SomaKit
//
//  Created by Anton on 24.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

extension Dictionary {
    public func mapValues<TNewValue>(transform: Value throws -> TNewValue) rethrows -> Dictionary<Key, TNewValue> {
        var newDictionary = Dictionary<Key, TNewValue>(minimumCapacity: count)
        
        for (key, value) in self {
            newDictionary[key] = try transform(value)
        }
        
        return newDictionary
    }
}

extension Array {
    public func indexOfEquivalent(object: Element) -> Int? {
        return indexOf({ (element) -> Bool in
            return Utils.isEquivalentValues(element, value2: object)
        })
    }
    
    public func optionalCovariance() -> [Element?] {
        return map(SomaFunc.sameTransform)
    }
}

extension Array: Equivalentable {
    public func isEquivalent(other: Array) -> Bool {
        guard count == other.count else {
            return false
        }
        
        for index in 0..<count {
            if !Utils.isEquivalentValues(self[index], value2: other[index]) {
                return false
            }
        }
        
        return true
    }
}