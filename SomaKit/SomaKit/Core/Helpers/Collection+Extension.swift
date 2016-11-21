//
//  Collection+Extension.swift
//  SomaKit
//
//  Created by Anton on 24.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

extension Dictionary {
    public func filterDictionary(_ isIncluded: (Key, Value) throws -> Bool) rethrows -> Dictionary<Key, Value> {
        var resultDictionary = Dictionary<Key, Value>(minimumCapacity: count)
        
        for (key, value) in self {
            if try isIncluded(key, value) {
                resultDictionary[key] = value
            }
        }
        
        return resultDictionary
    }
}
