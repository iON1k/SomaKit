//
//  TimeHelper.swift
//  SomaKit
//
//  Created by Anton on 17.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class TimeHelper {
    public static func absoluteTime() -> Double {
        return CFAbsoluteTimeGetCurrent()
    }
}
