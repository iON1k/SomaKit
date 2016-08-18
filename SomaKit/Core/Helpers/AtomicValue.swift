//
//  AtomicValue.swift
//  SomaKit
//
//  Created by Anton on 09.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class AtomicValue<TValue> {
    private var innerValue: TValue
    private let syncLock = SyncLock()
    
    public var value: TValue {
        get {
            return syncLock.sync {
                return innerValue
            }
        }
        
        set {
            syncLock.sync { 
                self.innerValue = value
            }
        }
    }
    
    public init(value: TValue) {
        self.innerValue = value
    }
}