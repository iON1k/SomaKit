//
//  TableViewManager+Extension.swift
//  SomaKit
//
//  Created by Anton on 07.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension TableViewManager {
    public func updateDataObservable(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let disposable = AnonymousDisposable() {
                observer.onCompleted()
            }
            
            let updatingEvent = UpdatingEvent(sectionsData: sectionsData, needPrepareData: false, disposable: disposable) { (tableView, updatingData) in
                updatingHandler(tableView: tableView, updatingData: updatingData)
                observer.onNext()
                observer.onCompleted()
            }
            
            self.updateData(updatingEvent)
            
            return disposable
        })
    }
    
    public func updateData(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return updateDataObservable(sectionsData, updatingHandler: updatingHandler)
            .subscribe()
    }
    
    public func updateDataAsyncObservable(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataObservable(sectionsData, updatingHandler: updatingHandler)
            .subcribeOnBackgroundScheduler()
    }
    
    public func updateDataAsync(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return updateDataAsyncObservable(sectionsData, updatingHandler: updatingHandler)
            .subscribe()
    }
    
    public func reloadDataObservable() -> Observable<Void> {
        return updateDataObservable(sectionsData)
    }
    
    public func reloadDataAsyncObservable() -> Observable<Void> {
        return updateDataAsyncObservable(sectionsData)
    }
    
    public func reloadData() -> Disposable {
        return reloadDataObservable()
            .subscribe()
    }
    
    public func reloadDataAsync() -> Disposable {
        return reloadDataAsyncObservable()
            .subscribe()
    }
    
    public func bindDataSource(dataSource: Observable<SectionsModels>, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return dataSource.doOnNext({ (sectionsData) in
            self.updateDataAsync(sectionsData, updatingHandler: updatingHandler)
        })
        .subscribe()
    }
}