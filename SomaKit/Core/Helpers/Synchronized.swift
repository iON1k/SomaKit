//
//  Synchronized.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public func beginSyncLock(lockObj: AnyObject) -> Void {
    objc_sync_enter(lockObj)
}

public func endSyncLock(lockObj: AnyObject) -> Void {
    objc_sync_exit(lockObj)
}

public func synchronized(lockObj: AnyObject, @noescape block: () -> Void) -> Void {
    beginSyncLock(lockObj)
    block()
    endSyncLock(lockObj)
}

public func synchronized<T>(lockObj: AnyObject, @noescape block: () -> T) -> T {
    beginSyncLock(lockObj)
    let result: T = block()
    endSyncLock(lockObj)
    
    return result
}

public class SyncLock {
    public func lock() {
        beginSyncLock(self)
    }
    
    public func unlock() {
        endSyncLock(self)
    }
    
    public func sync(@noescape block: () -> Void) {
        synchronized(self, block: block)
    }
    
    public func sync<T>(@noescape block: () -> T) -> T {
        return synchronized(self, block: block)
    }
}