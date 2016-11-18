//
//  AbstractDatabaseStore.swift
//  SomaKit
//
//  Created by Anton on 25.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import MagicalRecord
import RxSwift

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
    
    public func loadData(key: TKey) -> Observable<DataType?> {
        return Observable.deferred({ () -> Observable<DataType?> in
            return Observable.just(try self.beginLoadData(key: key))
        })
    }
    
    private func beginLoadData(key: TKey) throws -> DataType? {
        var resultData: TData? = nil
        
        if let dbRecord = DatabaseType.mr_findFirst(with: try keyPredicate(key)) {
            resultData = try getterHandler(dbRecord)
        }
        
        return resultData
    }
    
    public func storeData(key: TKey, data: TData?) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            self.dbContext.perform {
                self.beginStoreData(key: key, data: data, observer: observer)
            }
            
            return Disposables.create()
        })
    }
    
    private func beginStoreData(key: TKey, data: TData?, observer: AnyObserver<Void>) {
        do {
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
            
            dbContext.mr_save(options: .parentContexts, completion: { (_, error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext()
                    observer.onCompleted()
                }
            })
        } catch let error {
            observer.onError(error)
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
