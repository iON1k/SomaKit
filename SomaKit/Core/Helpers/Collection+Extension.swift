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

extension Array where Element: Equivalentable {
    public func indexOfEquivalent(object: Element) -> Int? {
        return indexOf({ (element) -> Bool in
            return element.isEquivalent(object)
        })
    }
}
