//
//  TableViewUpdater.swift
//  SomaKit
//
//  Created by Anton on 12.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class TableViewUpdater {
    private let tableViewProxy: TableViewProxy
    private let elementsProvider: TableElementsProvider
    private let updateEvents: Variable<TableViewUpdatingEvent>

    public private(set) var attributesCalculator: TableElementsAttributesCalculator
    public private(set) var sectionsModels: [TableViewSectionModel]

    public init(tableViewProxy: TableViewProxy, initialSectionsModels: [TableViewSectionModel],
                initialAttributesCalculator: TableElementsAttributesCalculator, elementsProvider: TableElementsProvider) {
        self.tableViewProxy = tableViewProxy
        self.sectionsModels = initialSectionsModels
        self.attributesCalculator = initialAttributesCalculator
        self.elementsProvider = elementsProvider
        
        updateEvents = Variable(TableViewUpdatingEvent(sectionsModels: sectionsModels))

        startObserveUpdatingEvents()
    }

    public func update(with event: TableViewUpdatingEvent) {
        updateEvents <= event
    }

    private func updateTableView(withData updatingData: UpdatingData) {
        Debug.ensureIsMainThread()

        sectionsModels = updatingData.event.sectionsModels
        attributesCalculator = updatingData.attributesCalculator

        tableViewProxy.update(dataSource: updatingData.dataSource, attributesCalculator: updatingData.attributesCalculator,
                              updatingHandler: updatingData.event.updatingHandler)
    }

    private func startObserveUpdatingEvents() {
        _ = updateEvents.asObservable()
            .map({ (event) -> Observable<UpdatingData> in
                return Observable.deferred({ [weak self] () -> Observable<UpdatingData> in
                    guard let strongSelf = self else {
                        return Observable.empty()
                    }

                    let dataSource = TableViewDataSource(sectionsModels: event.sectionsModels, elementsProvider: strongSelf.elementsProvider)
                    let attributesCalculator = TableElementsAttributesCalculator(engine: dataSource)
                    TableViewUpdater.prepareAttributesCalculator(attributesCalculator: attributesCalculator, sectionsModels: event.sectionsModels)
                    let updatingData = UpdatingData(event: event, dataSource: dataSource, attributesCalculator: attributesCalculator)
                    return Observable.just(updatingData)
                })
            })
            .concat()
            .observeOnMainScheduler()
            .do(onNext: { [weak self] updatingData in
                self?.updateTableView(withData: updatingData)
            })
            .subscribe()
    }

    private static func prepareAttributesCalculator(attributesCalculator: TableElementsAttributesCalculator, sectionsModels: [TableViewSectionModel]) {
        for (sectionIndex, sectionModel) in sectionsModels.enumerated() {
            attributesCalculator.reloadSectionHeaderAttributes(sectionIndex: sectionIndex)
            attributesCalculator.reloadSectionFooterAttributes(sectionIndex: sectionIndex)

            for (rowIndex, _) in sectionModel.cellsViewModels.enumerated() {
                attributesCalculator.reloadCellAttributes(sectionIndex: sectionIndex, rowIndex: rowIndex)
            }
        }
    }

    private struct UpdatingData {
        public let event: TableViewUpdatingEvent
        public let dataSource: TableViewDataSource
        public let attributesCalculator: TableElementsAttributesCalculator

        public init(event: TableViewUpdatingEvent, dataSource: TableViewDataSource, attributesCalculator: TableElementsAttributesCalculator) {
            self.event = event
            self.dataSource = dataSource
            self.attributesCalculator = attributesCalculator
        }
    }
}
