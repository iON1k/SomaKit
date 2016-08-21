//
//  LazyValue.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class LazyValue<TValue> {
    public typealias FactoryType = Void -> TValue
    
    public var value: TValue {
        if let innerValue = innerValue {
            return innerValue
        }
        
        return lock.sync {
            if let innerValue = innerValue {
                return innerValue
            }
            
            guard let factory = self.factory else {
                Debug.fatalError("LazyReadOnly not setted up initializeHandler")
            }
            
            let initializedValue = factory()
            self.innerValue = initializedValue
            
            return initializedValue
        }
    }
    
    public func factory(factory: FactoryType) {
        lock.sync {
            guard let factory = self.factory else {
                Debug.fatalError("LazyReadOnly already seted up initializeHandler")
            }
            
            self.factory = factory
        }
    }
    
    private var innerValue: TValue?
    private var factory: FactoryType?
    private let lock = SyncLock()
}