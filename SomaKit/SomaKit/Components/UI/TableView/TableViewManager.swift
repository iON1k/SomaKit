//
//  TableViewManager.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public class TableViewManager {
    private let tableViewUpdater: TableViewUpdater

    private let disposable: Disposable

    public var sectionsModels: [TableViewSectionModel] {
        return tableViewUpdater.sectionsModels
    }

    public init(tableView: UITableView, elementsFactories: [TableElementFactrory]) {
        Debug.ensureIsMainThread()

        let elementsProvider = TableElementsProvider(tableView: tableView, elementsFactories: elementsFactories)
        tableViewUpdater = TableViewUpdater(tableView: tableView, sectionsModels: [], elementsProvider: elementsProvider)

        let dataSourceDisposable = tableView.rx.setDataSource(tableViewUpdater.tableViewProxy)
        let delegateDisposable = tableView.rx.setDelegate(tableViewUpdater.tableViewProxy)

        disposable = Disposables.create {
            dataSourceDisposable.dispose()
            delegateDisposable.dispose()
        }
    }

    deinit {
        invalidate()
    }

    public func update(with event: TableViewUpdatingEvent) {
        tableViewUpdater.update(with: event)
    }

    public func invalidate() {
        Debug.ensureIsMainThread()
        disposable.dispose()
    }
    
    public var forwardObject: Any? {
        get {
            Debug.ensureIsMainThread()
            return tableViewUpdater.tableViewProxy.forwardObject
        }
    }

    public func setForwardObject(_ forwardObject: Any!, withRetain retain: Bool) {
        Debug.ensureIsMainThread()
        tableViewUpdater.tableViewProxy.setForwardObject(forwardObject, withRetain: retain)
    }
}
