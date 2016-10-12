//
//  AbstractDataBaseStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import MagicalRecord

open class AbstractDataBaseStore<TKey, TData, TDataBase: NSManagedObject>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias DataBaseType = TDataBase
    public typealias SetterHandlerType = (DataType, DataBaseType) throws -> Void
    public typealias GetterHandlerType = (DataBaseType) throws -> DataType
    
    open let keyProperty: String
    
    fileprivate let setterHandler: SetterHandlerType
    fileprivate let getterHandler: GetterHandlerType
    
    open func loadData(_ key: KeyType) throws -> DataType? {
        let optinalDBRecord = DataBaseType.mr_findFirst(with: try self.keyPredicate(key))
        
        guard let dbRecord = optinalDBRecord else {
            return nil
        }
        
        let resultData = try getterHandler(dbRecord)
        
        return resultData
    }
    
    open func saveData(_ key: KeyType, data: DataType?) throws {
        var error: Error?
        
        MagicalRecord.save( { (dbLocalContext) in
            do {
                var dbRecord = DataBaseType.mr_findFirst(with: try self.keyPredicate(key), in: dbLocalContext)
                
                guard let data = data else {
                    if let dbRecord = dbRecord {
                        let removingResult = dbRecord.mr_deleteEntity(in: dbLocalContext)
                        
                        if (!removingResult) {
                            throw SomaError("DataBase \(Utils.typeName(DataType.self)) entity removing failed")
                        }
                    }
                    
                    return
                }
                
                if dbRecord == nil {
                    dbRecord = DataBaseType.mr_createEntity(in: dbLocalContext)
                }
                
                guard let resultDBRecord = dbRecord else {
                    error = SomaError("DataBase \(Utils.typeName(DataType.self)) entity creating failed")
                    return
                }
                
                try self.setterHandler(data, resultDBRecord)
                (resultDBRecord as NSManagedObject).setValue(key, forKey: self.keyProperty)
            } catch let catchedError {
                error = catchedError
            }
        })
        
        if let error = error {
            throw error
        }
    }
    
    public init(keyProperty: String, setterHandler: @escaping SetterHandlerType, getterHandler: @escaping GetterHandlerType) {
        self.keyProperty = keyProperty
        self.setterHandler = setterHandler
        self.getterHandler = getterHandler
    }
    
    fileprivate func keyPredicate(_ key: KeyType) throws -> NSPredicate {
        return NSPredicate(format: "%K = %@", argumentArray: [self.keyProperty, key])
    }
}
