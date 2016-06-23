//
//  NativeLogProcessor.swift
//  SomaKit
//
//  Created by Anton on 12.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class NativeLogProcessor: LogProcessor {
    public func log(message: String, args: Any...) {
        print(message, args)
    }
}