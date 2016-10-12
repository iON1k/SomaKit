//
//  Log+Extension.swift
//  SomaKit
//
//  Created by Anton on 12.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

extension Log {
    public static func error(_ message: String, args: Any...) {
        log(.error, message: message, args: args)
    }
    
    public static func log(_ error: Error) {
        log(.error, message: "Error: \(error)")
    }
    
    public static func warning(_ message: String, args: Any...) {
        log(.warning, message: message, args: args)
    }
    
    public static func info(_ message: String, args: Any...) {
        log(.info, message: message, args: args)
    }
    
    public static func debug(_ message: String, args: Any...) {
        log(.debug, message: message, args: args)
    }
    
}
