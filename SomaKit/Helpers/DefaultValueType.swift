//
//  DefaultValueType.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol DefaultValueType {
    static var defaultValue: Self { get }
}

extension Optional: DefaultValueType {
    public static var defaultValue: Optional {
        return nil
    }
}