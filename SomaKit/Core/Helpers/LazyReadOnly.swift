//
//  LazyReadOnly.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class LazyReadOnly<TValue> {
    public typealias InitializeHandler = Void -> TValue
    
    public var value: TValue {
        if let innerValue = innerValue {
            return innerValue
        }
        
        return lock.sync { () -> TValue in
            if let innerValue = innerValue {
                return innerValue
            }
            
            guard let initializeHandler = self.initializeHandler else {
                fatalError("LazyReadOnly not set initializeHandler")
            }
            
            let initializedValue = initializeHandler()
            self.innerValue = initializedValue
            
            return initializedValue
        }
    }
    
    public func setupInitializeHandler(initializeHandler: InitializeHandler) {
        self.initializeHandler = initializeHandler
    }
    
    private var innerValue: TValue?
    private var initializeHandler: InitializeHandler?
    private let lock = SyncLock()
}