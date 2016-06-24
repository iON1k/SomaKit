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
    public typealias SourcePageDataLoader = AnyDataLoader<TData>
    
    private let dataSyncLock = SyncLock()
    private let pageProvidersSyncLock = SyncLock()
    
    private let dataVar: Variable<DataType>
    
    private let disposeBag = DisposeBag()
    
    private var pageProviders: [PageType : SourcePageDataLoader] = [:]
    
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
        return Observable.deferred({ () -> Observable<SourcePageDataLoader> in
            return Observable.just(self.getPageProvider(pageNumber))
        })
        .flatMap({ (pageProvider) -> Observable<PageDataType> in
            return pageProvider.loadData()
        })
    }
    
    private func getPageProvider(pageNumber: PageType) -> SourcePageDataLoader {
        return pageProvidersSyncLock.sync { () -> SourcePageDataLoader! in
            var pageProvider = pageProviders[pageNumber]
            
            if pageProvider == nil {
                pageProvider = _createPageDataProvider(pageNumber)
                pageProviders[pageNumber] = pageProvider
                
                pageProvider?.rxData()
                    .subscribeNext({ (newData) in
                        self.updatePageData(newData, pageNumber: pageNumber)
                    })
                    .addDisposableTo(disposeBag)
            }
            
            return pageProvider
        }
    }
    
    private func updatePageData(newPageData: PageDataType, pageNumber: PageType) {
        dataSyncLock.sync { 
            var newData = data
            newData[pageNumber] = newPageData
            dataVar.value = newData
        }
    }
    
    public func _createPageDataProvider(pageNumber: PageType) -> SourcePageDataLoader {
        abstractMethod(#function)
    }
}

extension PagedDataLoader {
    public convenience init() {
        self.init(defaultData: [:])
    }
}