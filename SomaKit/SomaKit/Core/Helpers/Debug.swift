//
//  Debug.swift
//  SomaKit
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class Debug {
    public static func fatalError(_ message: String? = nil) -> Never  {
        Swift.fatalError(message ?? "Unknown fatal error")
    }
    
    public static func error(_ message: String) {
#if DEVELOP_BUILD
        self.fatalError(message)
#else
        Log.debug(message)
#endif
    }
    
    public static func assert(_ assertion: @autoclosure (Void) -> Bool, message: String) {
#if DEVELOP_BUILD
        if !assertion() {
            fatalError(message)
        }
#endif
    }
    
    private init() {
        //Nothing
    }
}

extension Debug {
    public static func abstractMethod(_ methodName: String = "Method") -> Never  {
        fatalError("\(methodName) has not been implemented")
    }
    
    public static func ensureIsMainThread() {
        guard Thread.isMainThread else {
            Debug.fatalError("Is not main thread")
        }
    }
}
