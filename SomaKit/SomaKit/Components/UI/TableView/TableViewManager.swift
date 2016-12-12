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
    public let tableViewProxy: TableViewProxy
    private let tableViewUpdater: TableViewUpdater

    public var sectionsModels: [TableViewSectionModel] {
        return tableViewUpdater.sectionsModels
    }

    public init(tableView: UITableView, elementsFactories: [TableElementFactrory]) {
        Debug.ensureIsMainThread()

        let initialSectionsModels = [TableViewSectionModel]()
        let elementsProvider = TableElementsProvider(tableView: tableView, elementsFactories: elementsFactories)
        let dataSource = TableViewDataSource(sectionsModels: initialSectionsModels, elementsProvider: elementsProvider)
        let attributesCalculator = TableElementsAttributesCalculator(engine: dataSource)
        tableViewProxy = TableViewProxy(tableView: tableView, dataSource: dataSource, attributesCalculator: attributesCalculator)
        tableViewUpdater = TableViewUpdater(tableViewProxy: tableViewProxy, initialSectionsModels: initialSectionsModels,
                                            initialAttributesCalculator: attributesCalculator, elementsProvider: elementsProvider)
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
}
