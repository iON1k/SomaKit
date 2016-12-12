//
//  TableViewManager+Extension.swift
//  SomaKit
//
//  Created by Anton on 07.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

extension TableViewManager {
    public func update(sectionsModels: [TableViewSectionModel],
                       updatingHandler: @escaping TableViewUpdatingEvent.UpdatingHandler = TableViewUpdatingEvent.defaultUpdatingHandler) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            self.update(with: TableViewUpdatingEvent(sectionsModels: sectionsModels, updatingHandler: { (tableView) in
                updatingHandler(tableView)
                observer.onNext()
                observer.onCompleted()
            }))
            
            return Disposables.create()
        })
    }
    
    public func bind<TEventsSource: ObservableConvertibleType>(with eventsSource: TEventsSource) -> Disposable
        where TEventsSource.E == TableViewUpdatingEvent {
        return eventsSource.asObservable()
            .do(onNext: { (event) in
                self.update(with: event)
            })
            .subscribe()
    }
}
