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
            let eventUpdatingHandler: UpdatingHandler = { (tableView, updatingData) in
                updatingHandler(tableView: tableView, updatingData: updatingData)
                observer.onNext()
                observer.onCompleted()
            }
            
            let updatingEvent = UpdatingEvent(sectionsData: sectionsData, needPrepareData: false, updatingHandler: eventUpdatingHandler) {
                observer.onCompleted()
            }
            
            self.updateData(updatingEvent)
            
            return NopDisposable.instance
        })
    }
    
    public func updateData(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
        _ = updateDataObservable(sectionsData, updatingHandler: updatingHandler)
            .subscribe()
    }
    
    public func updateDataAsyncObservable(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataObservable(sectionsData, updatingHandler: updatingHandler)
            .subcribeOnBackgroundScheduler()
    }
    
    public func updateDataAsync(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
        _ = updateDataAsyncObservable(sectionsData, updatingHandler: updatingHandler)
            .subscribe()
    }
    
    public func reloadDataObservable(updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataObservable(actualSectionsData, updatingHandler: updatingHandler)
    }
    
    public func reloadDataAsyncObservable(updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataAsyncObservable(actualSectionsData, updatingHandler: updatingHandler)
    }
    
    public func reloadData(updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return reloadDataObservable(updatingHandler)
            .subscribe()
    }
    
    public func reloadDataAsync(updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return reloadDataAsyncObservable(updatingHandler)
            .subscribe()
    }
    
    public func bindDataSource(dataSource: Observable<SectionsModels>, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return dataSource.doOnNext({ (sectionsData) in
            self.updateDataAsync(sectionsData, updatingHandler: updatingHandler)
        })
        .subscribe()
    }
}