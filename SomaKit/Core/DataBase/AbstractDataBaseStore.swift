//
//  AbstractDataBaseStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import MagicalRecord

public class AbstractDataBaseStore<TKey: AnyObjectConvertiableType, TData, TDataBase: NSManagedObject>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias DataBaseType = TDataBase
    public typealias SetterHandlerType = (DataType, DataBaseType) throws -> Void
    public typealias GetterHandlerType = (DataBaseType) throws -> DataType
    
    public let keyProperty: String
    
    private let setterHandler: SetterHandlerType
    private let getterHandler: GetterHandlerType
    
    public func loadData(key: KeyType) throws -> DataType? {
        let optinalDBRecord = DataBaseType.MR_findFirstWithPredicate(self.keyPredicate(key))
        
        guard let dbRecord = optinalDBRecord else {
            return nil
        }
        
        let resultData = try getterHandler(dbRecord)
        
        return resultData
    }
    
    public func saveData(key: KeyType, data: DataType) throws {
        var error: ErrorType?
        
        MagicalRecord.saveWithBlockAndWait { (dbLocalContext) in
            do {
                var dbRecord = DataBaseType.MR_findFirstWithPredicate(self.keyPredicate(key), inContext: dbLocalContext)
                
                if dbRecord == nil {
                    dbRecord = DataBaseType.MR_createEntityInContext(dbLocalContext)
                }
                
                guard let resultDBRecord = dbRecord else {
                    let dataBaseName = typeName(TDataBase)
                    error = SomaError("DataBase \(dataBaseName) entity creating failed")
                    return
                }
                
                try self.setterHandler(data, resultDBRecord)
                (resultDBRecord as NSManagedObject).setValue(key.asAnyObject(), forKey: self.keyProperty)
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
    
    private func keyPredicate(key: KeyType) -> NSPredicate {
        return NSPredicate(format: "%K = %@", argumentArray: [self.keyProperty, key.asAnyObject()])
    }
}