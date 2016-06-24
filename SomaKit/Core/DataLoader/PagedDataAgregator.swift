//
//  PagedDataAgregator.swift
//  SomaKit
//
//  Created by Anton on 13.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class PagedDataAgregator<TData, TPageDataProvider: FetchableDataProvider
        where TPageDataProvider.DataType == TData>: DataAgregatorType {
    public typealias PageType = UInt
    public typealias PageDataType = TData
    public typealias DataType = [PageType : PageDataType]
    public typealias PageDataProviderType = TPageDataProvider
    
    private let dataSyncLock = SyncLock()
    private let pageProvidersSyncLock = SyncLock()
    
    private let dataVar = Variable<DataType>([:])
    
    private let disposeBag = DisposeBag()
    
    private var pageProviders: [PageType : PageDataProviderType] = [:]
    
    public var data: DataType {
        return dataVar.value
    }
    
    public func rxData() -> Observable<DataType> {
        return dataVar.asObservable()
    }
    
    public func loadPage(pageNumber: PageType) -> Observable<PageDataType> {
        return Observable.deferred({ () -> Observable<PageDataProviderType> in
            return Observable.just(self.getPageProvider(pageNumber))
        })
        .flatMap({ (pageProvider) -> Observable<PageDataType> in
            return pageProvider.fetchData()
        })
    }
    
    private func getPageProvider(pageNumber: PageType) -> PageDataProviderType {
        return pageProvidersSyncLock.sync { () -> PageDataProviderType! in
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
    
    public func _createPageDataProvider(pageNumber: PageType) -> PageDataProviderType {
        abstractMethod(#function)
    }
}