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
                Debug.fatalError("LazyValue not setted up factory")
            }
            
            let value = factory()
            self.innerValue = value
            
            return value
        }
    }
    
    public func factory(factory: FactoryType) {
        lock.sync {
            guard let factory = self.factory else {
                Debug.fatalError("LazyValue already seted up factory")
            }
            
            self.factory = factory
        }
    }
    
    private var innerValue: TValue?
    private var factory: FactoryType?
    private let lock = SyncLock()
}