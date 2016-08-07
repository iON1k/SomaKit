//
//  TableViewWrapper+Extension.swift
//  SomaKit
//
//  Created by Anton on 07.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension TableViewWrapper {
    public func updateDataObservable(sectionsData: SectionsModels, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let updatingEvent = UpdatingEvent(sectionsData: sectionsData, needPrepareData: false) { (tableView, updatingData) in
                updatingHandler(tableView: tableView, updatingData: updatingData)
                observer.onNext()
                observer.onCompleted()
            }
            
            self.updateData(updatingEvent)
            
            return updatingEvent.disposable
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
    
    public func reloadData() -> Disposable {
        return updateData(sectionsData)
    }
    
    public func reloadDataAsync() -> Disposable {
        return updateDataAsync(sectionsData)
    }
    
    public func bindDataSource(dataSource: Observable<SectionsModels>, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return dataSource.flatMapLatest({ (sectionsData) -> Observable<Void> in
            return self.updateDataAsyncObservable(sectionsData, updatingHandler: updatingHandler)
        })
        .subscribe()
    }
}
