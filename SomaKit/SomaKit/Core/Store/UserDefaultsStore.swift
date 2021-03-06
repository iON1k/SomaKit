//
//  UserDefaultsStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class UserDefaultsStore<TData: Any>: StoreType {
    public typealias KeyType = String
    public typealias DataType = TData
    
    private let userDefaults: UserDefaults
    
    public func loadData(key: String) throws -> TData? {
        let optionalSomeObject = userDefaults.object(forKey: key)

        guard let someObject = optionalSomeObject else {
            return nil
        }

        guard let resultData = someObject as? DataType else {
            throw SomaError("User defaults has no valid data \(type(of: (someObject))) for key \(key)")
        }

        return resultData
    }
    
    public func storeData(key: String, data: TData?) throws {
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
