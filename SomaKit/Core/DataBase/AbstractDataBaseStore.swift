//
//  AbstractDataBaseStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import MagicalRecord

public class AbstractDataBaseStore<TKey, TData, TDataBase: NSManagedObject>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias DataBaseType = TDataBase
    public typealias SetterHandlerType = (DataType, DataBaseType) throws -> Void
    public typealias GetterHandlerType = (DataBaseType) throws -> DataType
    
    public let keyProperty: String
    
    private let setterHandler: SetterHandlerType
    private let getterHandler: GetterHandlerType
    
    public func loadData(key: KeyType) throws -> DataType? {
        let optinalDBRecord = DataBaseType.MR_findFirstWithPredicate(try self.keyPredicate(key))
        
        guard let dbRecord = optinalDBRecord else {
            return nil
        }
        
        let resultData = try getterHandler(dbRecord)
        
        return resultData
    }
    
    public func saveData(key: KeyType, data: DataType?) throws {
        var error: ErrorType?
        
        MagicalRecord.saveWithBlockAndWait { (dbLocalContext) in
            do {
                var dbRecord = DataBaseType.MR_findFirstWithPredicate(try self.keyPredicate(key), inContext: dbLocalContext)
                
                guard let data = data else {
                    if let dbRecord = dbRecord {
                        let removingResult = dbRecord.MR_deleteEntityInContext(dbLocalContext)
                        
                        if (!removingResult) {
                            throw SomaError("DataBase \(Utils.typeName(TDataBase)) entity removing failed")
                        }
                    }
                    
                    return
                }
                
                if dbRecord == nil {
                    dbRecord = DataBaseType.MR_createEntityInContext(dbLocalContext)
                }
                
                guard let resultDBRecord = dbRecord else {
                    error = SomaError("DataBase \(Utils.typeName(TDataBase)) entity creating failed")
                    return
                }
                
                try self.setterHandler(data, resultDBRecord)
                (resultDBRecord as NSManagedObject).setValue(try self.keyObject(key), forKey: self.keyProperty)
            } catch let catchedError {
                error = catchedError
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    public init(keyProperty: String, setterHandler: SetterHandlerType, getterHandler: GetterHandlerType) {
        self.keyProperty = keyProperty
        self.setterHandler = setterHandler
        self.getterHandler = getterHandler
    }
    
    private func keyPredicate(key: KeyType) throws -> NSPredicate {
        return NSPredicate(format: "%K = %@", argumentArray: [self.keyProperty, try keyObject(key)])
    }
    
    private func keyObject(key: KeyType) throws -> AnyObject {
        guard let keyObj = key as? AnyObject else {
            throw SomaError("Database store wrong key type \(Utils.typeName(KeyType)). Expected type AnyObject.")
        }
        
        return keyObj
    }
}