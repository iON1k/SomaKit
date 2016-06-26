//
//  UserDefaultsStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class UserDefaultsStore<TData: AnyObject>: StoreType {
    public typealias KeyType = String
    public typealias DataType = TData
    
    private let userDefaults: NSUserDefaults
    
    public func loadData(key: KeyType) throws -> DataType? {
        let optionalSomeObject = userDefaults.objectForKey(key)
        
        guard let someObject = optionalSomeObject else {
            return nil
        }
        
        guard let resultData = someObject as? DataType else {
            throw SomaError("User defaults has no valid data \(someObject.dynamicType) for key \(key)")
        }
        
        return resultData
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        userDefaults.setObject(data, forKey: key)
    }
    
    public func removeData(key: KeyType) {
        userDefaults.removeObjectForKey(key)
    }
    
    public init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        self.userDefaults = userDefaults
    }
}