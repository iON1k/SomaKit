//
//  DataProvider.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol DataProviderType {
    associatedtype DataType
    func rxData() -> Observable<DataType>
}