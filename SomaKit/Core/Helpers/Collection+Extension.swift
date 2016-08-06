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
}
