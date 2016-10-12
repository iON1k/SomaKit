//
//  Synchronized.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public func beginSyncLock(_ lockObj: Any) -> Void {
    objc_sync_enter(lockObj)
}

public func endSyncLock(_ lockObj: Any) -> Void {
    objc_sync_exit(lockObj)
}

public func synchronized(lockObj: Any, block: () throws -> Void) rethrows -> Void {
    beginSyncLock(lockObj)
    try block()
    endSyncLock(lockObj)
}

public func synchronized<T>(lockObj: Any, block: () throws -> T) rethrows -> T {
    beginSyncLock(lockObj)
    let result: T = try block()
    endSyncLock(lockObj)
    
    return result
}

open class SyncLock {
    open func lock() {
        beginSyncLock(self)
    }
    
    open func unlock() {
        endSyncLock(self)
    }
    
    open func sync(block: () throws -> Void) rethrows {
        try synchronized(lockObj: self, block: block)
    }
    
    open func sync<T>(block: () throws -> T) rethrows -> T {
        return try synchronized(lockObj: self, block: block)
    }
}
