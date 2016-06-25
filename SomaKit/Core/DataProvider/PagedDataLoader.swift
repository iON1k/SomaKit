//
//  PagedDataLoader.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class PagedDataLoader<TData>: DataProviderType {
    public typealias PageType = UInt
    public typealias PageDataType = TData
    public typealias DataType = [PageType : PageDataType]
    
    private let dataSyncLock = SyncLock()
    private let dataVar: Variable<DataType>
    
    public var data: DataType {
        return dataVar.value
    }
    
    public init(let defaultData: DataType) {
        dataVar = Variable<DataType>(defaultData)
    }
    
    public func rxData() -> Observable<DataType> {
        return dataVar.asObservable()
    }
    
    public func loadPage(pageNumber: PageType) -> Observable<PageDataType> {
        return Observable.deferred({ () -> Observable<Observable<TData>> in
            return Observable.just(self._createPageDataProvider(pageNumber))
        })
        .flatMap({ (pageProvider) -> Observable<PageDataType> in
            return pageProvider
        })
        .doOnNext({ (newData) in
            self.updatePageData(newData, pageNumber: pageNumber)
        })
    }
    
    private func updatePageData(newPageData: PageDataType, pageNumber: PageType) {
        dataSyncLock.sync { 
            var newData = data
            newData[pageNumber] = newPageData
            dataVar.value = newData
        }
    }
    
    public func _createPageDataProvider(pageNumber: PageType) -> Observable<TData> {
        abstractMethod(#function)
    }
}

extension PagedDataLoader {
    public convenience init() {
        self.init(defaultData: [:])
    }
}