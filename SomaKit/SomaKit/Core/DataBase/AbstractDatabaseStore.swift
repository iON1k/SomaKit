//
//  AbstractDatabaseStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import MagicalRecord

open class AbstractDatabaseStore<TKey, TData, TDatabase: NSManagedObject>: StoreType {
    public typealias KeyType = TKey
    public typealias DataType = TData
    public typealias DatabaseType = TDatabase
    public typealias SetterHandlerType = (DataType, DatabaseType) throws -> Void
    public typealias GetterHandlerType = (DatabaseType) throws -> DataType
    
    public let keyProperty: String
    public let dbContext: NSManagedObjectContext
    
    private let setterHandler: SetterHandlerType
    private let getterHandler: GetterHandlerType
    
    public func loadData(key: TKey) throws -> TData? {
        var resultData: TData?
        var error: Error?

        dbContext.performAndWait {
            do {
                resultData = try self.beginLoadData(key: key)
            } catch let catchedError {
                error = catchedError
            }
        }

        if let error = error {
            throw error
        }

        return resultData
    }

    private func beginLoadData(key: TKey) throws -> TData? {
        guard let dbRecord = DatabaseType.mr_findFirst(with: try self.keyPredicate(key)) else {
            return nil
        }

        return try self.getterHandler(dbRecord)
    }

    public func storeData(key: TKey, data: TData?) throws {
        var error: Error?

        dbContext.performAndWait {
            do {
                try self.beginStoreData(key: key, data: data)
            } catch let catchedError {
                error = catchedError
            }
        }

        if let error = error {
            throw error
        }
    }

    private func beginStoreData(key: TKey, data: TData?) throws {
        var dbRecord = DatabaseType.mr_findFirst(with: try keyPredicate(key), in: dbContext)

        if let data = data {
            if dbRecord == nil {
                dbRecord = DatabaseType.mr_createEntity(in: dbContext)
            }

            guard let resultDBRecord = dbRecord else {
                throw SomaError("Database \(Utils.typeName(DataType.self)) entity creating failed")
            }

            try setterHandler(data, resultDBRecord)
            (resultDBRecord as NSManagedObject).setValue(key, forKey: keyProperty)
        } else {
            if let dbRecord = dbRecord {
                let removingResult = dbRecord.mr_deleteEntity(in: dbContext)

                if (!removingResult) {
                    throw SomaError("Database \(Utils.typeName(DataType.self)) entity removing failed")
                }
            }
        }

        var savingError: Error?
        dbContext.mr_save(options: [.parentContexts, .synchronously], completion: { (_, error) in
            savingError = error
        })

        if let savingError = savingError {
            throw savingError
        }
    }

    public init(dbContext: NSManagedObjectContext, keyProperty: String,
                setterHandler: @escaping SetterHandlerType, getterHandler: @escaping GetterHandlerType) {
        self.dbContext = dbContext
        self.keyProperty = keyProperty
        self.setterHandler = setterHandler
        self.getterHandler = getterHandler
    }
    
    private func keyPredicate(_ key: KeyType) throws -> NSPredicate {
        return NSPredicate(format: "%K = %@", argumentArray: [self.keyProperty, key])
    }
}
