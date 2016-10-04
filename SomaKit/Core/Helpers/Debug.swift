//
//  Debug.swift
//  SomaKit
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class Debug {
    @noreturn public static func fatalError(message: String? = nil) {
        Swift.fatalError(message ?? "Unknown fatal error")
    }
    
    public static func error(message: String) {
#if DEVELOP_BUILD
        self.fatalError(message)
#else
        Log.debug(message)
#endif
    }
    
    public static func assert(@autoclosure assertion: Void -> Bool, message: String) {
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
