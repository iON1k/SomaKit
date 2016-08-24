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

public func synchronized(lockObj: AnyObject, @noescape block: () throws -> Void) rethrows -> Void {
    beginSyncLock(lockObj)
    try block()
    endSyncLock(lockObj)
}

public func synchronized<T>(lockObj: AnyObject, @noescape block: () throws -> T) rethrows -> T {
    beginSyncLock(lockObj)
    let result: T = try block()
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
    
    public func sync(@noescape block: () throws -> Void) rethrows {
        try synchronized(self, block: block)
    }
    
    public func sync<T>(@noescape block: () throws -> T) rethrows -> T {
        return try synchronized(self, block: block)
    }
}