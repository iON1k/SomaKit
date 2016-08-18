//
//  LazyValue.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class LazyValue<TValue> {
    public typealias InitializeHandler = Void -> TValue
    
    public var value: TValue {
        if let innerValue = innerValue {
            return innerValue
        }
        
        return lock.sync {
            if let innerValue = innerValue {
                return innerValue
            }
            
            guard let initializeHandler = self.initializeHandler else {
                Debug.fatalError("LazyReadOnly not setted up initializeHandler")
            }
            
            let initializedValue = initializeHandler()
            self.innerValue = initializedValue
            
            return initializedValue
        }
    }
    
    public func initialize(initializeHandler: InitializeHandler) {
        lock.sync {
            guard let initializeHandler = self.initializeHandler else {
                Debug.fatalError("LazyReadOnly already seted up initializeHandler")
            }
            
            self.initializeHandler = initializeHandler
        }
    }
    
    private var innerValue: TValue?
    private var initializeHandler: InitializeHandler?
    private let lock = SyncLock()
}