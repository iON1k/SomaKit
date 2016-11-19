//
//  AbstractAnchoredPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 25.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class AbstractAnchoredPagedDataProvider<TPage: AnchoredPageType>: AbstractPagedDataProvider<TPage> {  
    private var anchoredPage: PageType?
    private var isAnchoredPageLoadingVariable = Variable<Bool>(false)
    
    public override init(pageSize: Int, memoryCache: MemoryCacheType) {
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public final override func _createPageLoadingObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        let isAnchoredPageLoading = isAnchoredPageLoadingVariable.value
        
        if let anchoredPage = anchoredPage, !isAnchoredPageLoading  {
            return _createAnchoredPageLoadingObservable(offset, count: count, anchoredPage: anchoredPage)
        }
        
        if isAnchoredPageLoading {
            return isAnchoredPageLoadingVariable.asObservable()
                .filter(SomaFunc.negativePredicate)
                .take(1)
                .flatMap({ (_) -> Observable<PageType> in
                    return self._createPageLoadingObservable(offset, count: count)
                })
        }
        
        isAnchoredPageLoadingVariable <= true
        return wrapAnchorLoadingPageObservable(_createAnchoredPageLoadingObservable(offset, count: count, anchoredPage: nil))
    }
    
    private func wrapAnchorLoadingPageObservable(_ sourceObservable: Observable<PageType>) -> Observable<PageType> {
        return sourceObservable
            .subscribeOn(_workingScheduler)
            .do(onNext: { (page) in
                    self.anchoredPage = page
                }, onDispose: { 
                    self.isAnchoredPageLoadingVariable <= false
                })
    }
    
    open func _createAnchoredPageLoadingObservable(_ offset: Int, count: Int, anchoredPage: PageType?) -> Observable<PageType> {
        Debug.abstractMethod()
    }
}
