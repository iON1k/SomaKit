//
//  FactoryType.swift
//  SomaKit
//
//  Created by Anton on 25.10.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public protocol FactoryType {
    associatedtype InstanceType
    associatedtype Instance
    
    func createInstance(type: InstanceType) -> Instance
}
