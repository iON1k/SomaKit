//
//  Debug.swift
//  SomaKit
//
//  Created by Anton on 29.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class Debug {
    @noreturn public static func fatalError(message: String? = nil) {
        fatalError(message)
    }
    
    public static func error(message: String) {
#if CRASH_ON_ERROR
    self.fatalError(message)
#else
    Log.debug(message)
#endif
    }
    
    private init() {
        //Nothing
    }
}
