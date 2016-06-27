//
//  UserDefaultsStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class UserDefaultsStore<TKey: StringKeyConvertiable, TData: AnyObject>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    
    private let userDefaults: NSUserDefaults
    
    public func loadData(key: KeyType) throws -> DataType? {
        let stringKey = key.stringKey
        let optionalSomeObject = userDefaults.objectForKey(stringKey)
        
        guard let someObject = optionalSomeObject else {
            return nil
        }
        
        guard let resultData = someObject as? DataType else {
            throw SomaError("User defaults has no valid data \(someObject.dynamicType) for key \(stringKey)")
        }
        
        return resultData
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        userDefaults.setObject(data, forKey: key.stringKey)
    }
    
    public func removeData(key: KeyType) {
        userDefaults.removeObjectForKey(key.stringKey)
    }
    
    public init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.userDefaults = userDefaults
    }
}