//
//  DataLoader.swift
//  SomaKit
//
//  Created by Anton on 19.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol DataLoaderType: DataProviderType {
    func loadData() -> Observable<DataType>
}

extension DataProviderType {
    func loadData() -> Observable<DataType> {
        return Observable.empty()
    }
}