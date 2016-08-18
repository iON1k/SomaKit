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
    public func indexOfEquivalent(object: Equivalentable) -> Int? {
        return indexOf({ (element) -> Bool in
            return object.isEquivalent(element)
        })
    }
    
    public func optionalCovariance() -> [Element?] {
        return map(SomaFunc.sameTransform)
    }
}

extension Array: Equivalentable {
    public func isEquivalent(other: Any) -> Bool {
        guard let otherArray = other as? [Element] else {
            return false
        }
        
        guard count == otherArray.count else {
            return false
        }
        
        for index in 0..<count {
            if !Utils.isEquivalentValues(self[index], value2: otherArray[index]) {
                return false
            }
        }
        
        return true
    }
}