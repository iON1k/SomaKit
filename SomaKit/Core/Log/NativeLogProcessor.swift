//
//  NativeLogProcessor.swift
//  SomaKit
//
//  Created by Anton on 12.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

open class NativeLogProcessor: LogProcessor {
    open func log(_ message: String, args: Any...) {
        print(message, args)
    }
}
