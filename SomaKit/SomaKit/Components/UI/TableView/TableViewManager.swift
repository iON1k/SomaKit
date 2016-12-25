//
//  TableViewManager.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public class TableViewManager: TableViewUpdaterDelegate {
    public let tableViewProxy: TableViewProxy
    private let tableViewUpdater: TableViewUpdater

    public private(set) var sectionsModels: [TableViewSectionModel]
    public private(set) var attributesCalculator: TableElementsAttributesCalculator

    public init(tableView: UITableView, elementsProvider: TableElementsProvider) {
        Debug.ensureIsMainThread()

        sectionsModels = [TableViewSectionModel]()
        let elementsProvider = elementsProvider
        let dataSource = TableViewDataSource(sectionsModels: sectionsModels, elementsProvider: elementsProvider)
        attributesCalculator = TableElementsAttributesCalculator(engine: dataSource)
        tableViewProxy = TableViewProxy(tableView: tableView, dataSource: dataSource, attributesCalculator: attributesCalculator)
        tableViewUpdater = TableViewUpdater(tableViewProxy: tableViewProxy, elementsProvider: elementsProvider)
    }

    public func update(with event: TableViewUpdatingEvent) {
        tableViewUpdater.update(with: event)
    }
    
    public var forwardObject: Any? {
        get {
            Debug.ensureIsMainThread()
            return tableViewProxy.forwardObject
        }
    }

    public func setForwardObject(_ forwardObject: Any!, withRetain retain: Bool) {
        Debug.ensureIsMainThread()
        tableViewProxy.setForwardObject(forwardObject, withRetain: retain)
    }

    public func tableViewUpdaterDidUpdated(tableViewUpdater: TableViewUpdater, updatingData: TableViewUpdater.UpdatingData) {
        sectionsModels = updatingData.event.sectionsModels
        attributesCalculator = updatingData.attributesCalculator
    }
}
