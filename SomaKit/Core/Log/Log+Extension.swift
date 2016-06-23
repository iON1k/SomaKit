//
//  Log+Extension.swift
//  SomaKit
//
//  Created by Anton on 12.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

extension Log {
    public static func initialize(logPriority: LogPriority) {
        initialize(NativeLogProcessor(), logPriority: logPriority)
    }
    
    public static func initialize() {
        initialize(.Info)
    }
    
    public static func error(message: String, args: Any...) {
        log(.Error, message: message, args: args)
    }
    
    public static func warning(message: String, args: Any...) {
        log(.Warning, message: message, args: args)
    }
    
    public static func info(message: String, args: Any...) {
        log(.Info, message: message, args: args)
    }
    
    public static func debug(message: String, args: Any...) {
        log(.Debug, message: message, args: args)
    }
    
}