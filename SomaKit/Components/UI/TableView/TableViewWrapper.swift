//
//  TableViewWrapper.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public class TableViewWrapper: NSObject, UITableViewDataSource, UITableViewDelegate, TableElementAttributesCacheSource {
    public let tableView: UITableView
    
    public typealias SectionModels = [TableViewSectionModel]
    
    private let elementsAttributesCache = TableElementAttributesCache()
    private let elementsProvider: TableElementsProvider
    
    private let sectionsModels = Variable(SectionModels())
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        elementsProvider = TableElementsProvider(tableView: tableView)
        
        super.init()
        
        elementsAttributesCache.bindSource(self)
        
        tableView.rx_delegate.setForwardToDelegate(self, retainDelegate: false)
        tableView.rx_dataSource.setForwardToDelegate(self, retainDelegate: false)
        
        _ = sectionsModels.asObservable()
            .flatMapLatest({ [weak self] (sectionsModels) -> Observable<Void> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                
                return strongSelf.tableViewUpdatingObservable(sectionsModels)
            })
            .takeUntil(rx_deallocated)
            .subscribe()
    }
    
    public func bindDataSource(dataSource: Observable<SectionModels>) -> Disposable {
        return dataSource.bindTo(sectionsModels)
    }
    
    //TableElementAttributesCacheSource
    
    public func tableElementAttributes(tableElementAttributesCache: TableElementAttributesCache, indexPath: NSIndexPath) -> TableElementAttributes {
        return elementsAttributesCache .tableElementAttributes(indexPath)
    }
    
    //UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount()
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount(section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let viewModel = cellViewModel(indexPath)
        return elementsProvider.cellForViewModel(viewModel)
    }
    
    private func cellViewModel(indexPath: NSIndexPath) -> ViewModelType {
        return sectionModel(indexPath.section).cellsViewModels[indexPath.row]
    }
    
    private func sectionModel(sectionIndex: Int) -> TableViewSectionModel {
        return currentSections()[sectionIndex]
    }
    
    private func rowsCount(sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex).cellsViewModels.count
    }
    
    private func sectionsCount() -> Int {
        return currentSections().count
    }
    
    private func currentSections() -> SectionModels {
        return sectionsModels.value
    }
    
    private func tableViewUpdatingObservable(sectionsModels: SectionModels) -> Observable<Void> {
        elementsAttributesCache.invalidateCache()
        tableView.reloadData()
        
        //TODO: ???
        return Observable.just()
    }
}