//
//  AbstractAnchoredPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 25.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class AbstractAnchoredPagedDataProvider<TPage: AnchoredPageType>: AbstractPagedDataProvider<TPage> {  
    private var anchoredPage: PageType?
    private var isAnchoredPageLoading = Variable<Bool>(false)
    private let syncLock = SyncLock()
    
    public override init(pageSize: Int, memoryCache: MemoryCacheType) {
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public final override func _createLoadingPageObservable(offset: Int, count: Int) -> Observable<PageType> {
        return Observable.deferred({ () -> Observable<PageType> in
            return self.beginPageLoading(offset, count: count)
        })
    }
    
    public final func beginPageLoading(offset: Int, count: Int) -> Observable<PageType> {
        return syncLock.sync {
            return unsafeBeginPageLoading(offset, count: count)
        }
    }
    
    public final func unsafeBeginPageLoading(offset: Int, count: Int) -> Observable<PageType> {
        if let anchoredPage = anchoredPage {
            return _createLoadingAnchoredPageObservable(offset, count: count, anchoredPage: anchoredPage)
        }
        
        if isAnchoredPageLoading.value {
            return isAnchoredPageLoading.asObservable()
                .filter(SomaFunc.negativePredicate)
                .take(1)
                .flatMap({ (_) -> Observable<PageType> in
                    return self._createLoadingPageObservable(offset, count: count)
                })
        }
        
        isAnchoredPageLoading <= true
        return wrapAnchorLoadingPageObservable(_createLoadingAnchoredPageObservable(offset, count: count, anchoredPage: nil))
    }
    
    private func wrapAnchorLoadingPageObservable(sourceObservable: Observable<PageType>) -> Observable<PageType> {
        return Observable.create({ (observer) -> Disposable in
            let lastLoadedPage = AtomicValue<PageType?>(value: nil)
            
            let sourceDisposable = sourceObservable.subscribe({ (event) in
                switch event {
                case .Next(let page):
                    lastLoadedPage.value = page
                case .Completed, .Error:
                    self.onAnchoredPageLoadingDidCompleted(lastLoadedPage.value)
                }
            })
            
            return AnonymousDisposable {
                sourceDisposable.dispose()
                self.onAnchoredPageLoadingDidCompleted(nil)
            }
        })
    }
    
    private func onAnchoredPageLoadingDidCompleted(loadedPage: PageType?) {
        syncLock.sync {
            if let loadedPage = loadedPage {
                anchoredPage = loadedPage
            }
            
            isAnchoredPageLoading <= false
        }
    }
    
    public func _createLoadingAnchoredPageObservable(offset: Int, count: Int, anchoredPage: PageType?) -> Observable<PageType> {
        Utils.abstractMethod()
    }
}