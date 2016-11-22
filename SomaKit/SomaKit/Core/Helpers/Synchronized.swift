//
//  Synchronized.swift
//  SomaKit
//
//  Created by Anton on 15.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//


public final class Sync {
    public final class Lock {
        public func lock() {
            Sync.beginSyncLock(self)
        }
        
        public func unlock() {
            Sync.endSyncLock(self)
        }
        
        public func sync(block: () throws -> Void) rethrows {
            try Sync.synchronized(lockObj: self, block: block)
        }
        
        public func sync<T>(block: () throws -> T) rethrows -> T {
            return try Sync.synchronized(lockObj: self, block: block)
        }
    }
    
    public static func beginSyncLock(_ lockObj: Any) -> Void {
        objc_sync_enter(lockObj)
    }
    
    public static func endSyncLock(_ lockObj: Any) -> Void {
        objc_sync_exit(lockObj)
    }
    
    public static func synchronized(lockObj: Any, block: () throws -> Void) rethrows -> Void {
        beginSyncLock(lockObj)
        try block()
        endSyncLock(lockObj)
    }
    
    public static func synchronized<T>(lockObj: Any, block: () throws -> T) rethrows -> T {
        beginSyncLock(lockObj)
        let result: T = try block()
        endSyncLock(lockObj)
        
        return result
    }
}
