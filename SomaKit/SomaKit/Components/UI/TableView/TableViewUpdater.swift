//
//  TableViewUpdater.swift
//  SomaKit
//
//  Created by Anton on 12.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class TableViewUpdater {
    public let tableViewProxy: TableViewProxy
    private let elementsProvider: TableElementsProvider

    private let tableView: UITableView
    private let updateEvents: Variable<TableViewUpdatingEvent>

    public private(set) var attributesCalculator: TableElementsAttributesCalculator
    public private(set) var sectionsModels: [TableViewSectionModel]

    public init(tableView: UITableView, sectionsModels: [TableViewSectionModel], elementsProvider: TableElementsProvider) {
        self.tableView = tableView
        self.sectionsModels = sectionsModels
        self.elementsProvider = elementsProvider
        
        updateEvents = Variable(TableViewUpdatingEvent(sectionsModels: sectionsModels))

        let dataSource = TableViewDataSource(sectionsModels: sectionsModels, elementsProvider: elementsProvider)
        attributesCalculator = TableElementsAttributesCalculator(engine: dataSource)
        tableViewProxy = TableViewProxy(dataSource: dataSource, attributesCalculator: attributesCalculator)

        startObserveUpdatingEvents()
    }

    public func update(with event: TableViewUpdatingEvent) {
        updateEvents <= event
    }

    private func updateTableView(withData updatingData: UpdatingData) {
        Debug.ensureIsMainThread()

        sectionsModels = updatingData.event.sectionsModels
        attributesCalculator = updatingData.attributesCalcualtor

        updatingData.event.updatingHandler(tableView)
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
                    let updatingData = UpdatingData(event: event, dataSource: dataSource, attributesCalcualtor: attributesCalculator)
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
        public let attributesCalcualtor: TableElementsAttributesCalculator

        public init(event: TableViewUpdatingEvent, dataSource: TableViewDataSource, attributesCalcualtor: TableElementsAttributesCalculator) {
            self.event = event
            self.dataSource = dataSource
            self.attributesCalcualtor = attributesCalcualtor
        }
    }
}
