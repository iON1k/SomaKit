//
//  ObjectGenerator.swift
//  SomaKit
//
//  Created by Anton on 11.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class ObjectGenerator<TObject> {
    public typealias GenerationHandlerType = Void -> TObject
    
    private let generationHandler: GenerationHandlerType
    private var objectsPool: [TObject] = []
    private let poolLock = SyncLock()
    
    private init(generationHandler: GenerationHandlerType) {
        self.generationHandler = generationHandler
    }
    
    public static func generator(generationHandler: GenerationHandlerType) -> Self {
        return self.init(generationHandler: generationHandler)
    }
    
    public static func generator(generationHandler: GenerationHandlerType, poolSize: UInt) -> Self {
        let generator = self.generator(generationHandler)
        generator.fillPool(poolSize)
        
        return generator
    }
    
    public func fillPool(count: UInt) {
        poolLock.sync { 
            for _ in 0..<count {
                objectsPool.append(getNewObject())
            }
        }
    }
    
    public func generate() -> TObject {
        let objectFromPool = poolLock.sync { () -> TObject? in
            return objectsPool.popLast()
        }
        
        if let objectFromPool = objectFromPool {
            return objectFromPool
        }
        
        return getNewObject()
    }
    
    private func getNewObject() -> TObject {
        return generationHandler()
    }
}