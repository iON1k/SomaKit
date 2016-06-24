//
//  FetchableDataProvider.swift
//  SomaKit
//
//  Created by Anton on 19.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol FetchableDataProvider: DataProviderType {
    func fetchData() -> Observable<DataType>
}