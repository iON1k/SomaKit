//
//  UserDefaultsStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

open class UserDefaultsStore<TData: Any>: StoreType {
    public typealias KeyType = String
    public typealias DataType = TData
    
    private let userDefaults: UserDefaults
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        let stringKey = key
        let optionalSomeObject = userDefaults.object(forKey: stringKey)
        
        guard let someObject = optionalSomeObject else {
            return nil
        }
        
        guard let resultData = someObject as? DataType else {
            throw SomaError("User defaults has no valid data \(type(of: (someObject))) for key \(stringKey)")
        }
        
        return resultData
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        guard let data = data else {
            userDefaults.removeObject(forKey: key)
            return
        }
        
        userDefaults.set(data, forKey: key)
    }
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
}
