//
//  AbstractAnchoredPagedDataProvider.swift
//  SomaKit
//
//  Created by Anton on 25.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class AbstractAnchoredPagedDataProvider<TPage: AnchoredPageType>: AbstractPagedDataProvider<TPage> {  
    fileprivate var anchoredPage: PageType?
    fileprivate var isAnchoredPageLoading = Variable<Bool>(false)
    fileprivate let syncLock = SyncLock()
    
    public override init(pageSize: Int, memoryCache: MemoryCacheType) {
        super.init(pageSize: pageSize, memoryCache: memoryCache)
    }
    
    public final override func _createLoadingPageObservable(_ offset: Int, count: Int) -> Observable<PageType> {
        return Observable.deferred({ () -> Observable<PageType> in
            return self.beginPageLoading(offset, count: count)
        })
    }
    
    public final func beginPageLoading(_ offset: Int, count: Int) -> Observable<PageType> {
        return syncLock.sync {
            return unsafeBeginPageLoading(offset, count: count)
        }
    }
    
    public final func unsafeBeginPageLoading(_ offset: Int, count: Int) -> Observable<PageType> {
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
    
    fileprivate func wrapAnchorLoadingPageObservable(_ sourceObservable: Observable<PageType>) -> Observable<PageType> {
        return Observable.create({ (observer) -> Disposable in
            let lastLoadedPage = AtomicValue<PageType?>(value: nil)
            
            let sourceDisposable = sourceObservable.subscribe({ (event) in
                switch event {
                case .next(let page):
                    lastLoadedPage.value = page
                case .completed, .error:
                    self.onAnchoredPageLoadingDidCompleted(lastLoadedPage.value)
                }
            })
            
            return Disposables.create {
                sourceDisposable.dispose()
                self.onAnchoredPageLoadingDidCompleted(nil)
            }
        })
    }
    
    fileprivate func onAnchoredPageLoadingDidCompleted(_ loadedPage: PageType?) {
        syncLock.sync {
            if let loadedPage = loadedPage {
                anchoredPage = loadedPage
            }
            
            isAnchoredPageLoading <= false
        }
    }
    
    open func _createLoadingAnchoredPageObservable(_ offset: Int, count: Int, anchoredPage: PageType?) -> Observable<PageType> {
        Utils.abstractMethod()
    }
}
