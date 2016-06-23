//
//  SomaError.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public struct SomaError: ErrorType, CustomStringConvertible {
    private let errorDescription: String
    
    public init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
    
    public var description: String {
        return errorDescription
    }
}
