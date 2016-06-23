//
//  DataAgregator.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation
import RxSwift

public protocol DataAgregator: DataProvider {
    var data: DataType { get }
}