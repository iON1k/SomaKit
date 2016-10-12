//
//  TableViewManager+Extension.swift
//  SomaKit
//
//  Created by Anton on 07.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension Array where Element: ViewModelType {
    public func asTableViewSectionsModels() -> TableViewManager.SectionsModels {
        let sectionsModels = TableViewSectionModel(cellsViewModels: self.map(SomaFunc.sameTransform))
        return [sectionsModels]
    }
}

extension TableViewManager {
    public func updateDataObservable(_ sectionsData: SectionsModels, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let eventUpdatingHandler: UpdatingHandler = { (tableView, updatingData) in
                updatingHandler(tableView, updatingData)
                observer.onNext()
                observer.onCompleted()
            }
            
            let updatingEvent = UpdatingEvent(sectionsData: sectionsData, needPrepareData: false, updatingHandler: eventUpdatingHandler)
            
            self.updateData(updatingEvent)
            
            return updatingEvent.disposable
        })
    }
    
    public func updateData(_ sectionsData: SectionsModels, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
        _ = updateDataObservable(sectionsData, updatingHandler: updatingHandler)
            .subscribe()
    }
    
    public func updateDataAsyncObservable(_ sectionsData: SectionsModels, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataObservable(sectionsData, updatingHandler: updatingHandler)
            .subcribeOnBackgroundScheduler()
    }
    
    public func updateDataAsync(_ sectionsData: SectionsModels, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
        _ = updateDataAsyncObservable(sectionsData, updatingHandler: updatingHandler)
            .subscribe()
    }
    
    public func reloadDataObservable(_ updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataObservable(actualSectionsData, updatingHandler: updatingHandler)
    }
    
    public func reloadDataAsyncObservable(_ updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return updateDataAsyncObservable(actualSectionsData, updatingHandler: updatingHandler)
    }
    
    public func reloadData(_ updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return reloadDataObservable(updatingHandler)
            .subscribe()
    }
    
    public func reloadDataAsync(_ updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable {
        return reloadDataAsyncObservable(updatingHandler)
            .subscribe()
    }
    
    public func bindDataSource<TDataSource: ObservableConvertibleType>(_ dataSource: TDataSource, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) -> Disposable
        where TDataSource.E == SectionsModels {
        return dataSource.asObservable()
            .do(onNext: { (sectionsData) in
                self.updateDataAsync(sectionsData, updatingHandler: updatingHandler)
            })
            .subscribe()
    }
}
