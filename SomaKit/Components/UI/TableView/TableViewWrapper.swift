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
    
    private let defaultElementsAttributes = DefaultTableElementAttributes(prefferedHeight: 10)
    
    private let sectionsModels = Variable(SectionModels())
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        elementsProvider = TableElementsProvider(tableView: tableView)
        
        super.init()
        
        elementsAttributesCache.source = self
        
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
    
    public func cellAttributes(tableElementAttributesCache: TableElementAttributesCache, indexPath: NSIndexPath) -> TableElementAttributes {
        let viewModel = cellViewModel(indexPath)
        return generateTableElementAttributes(viewModel)
    }
    
    public func sectionHeaderAttributes(tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributes {
        guard let viewModel = headerViewModel(sectionIndex) else {
            Debug.error("Section model with index \(sectionIndex) no has header model")
            return defaultElementsAttributes
        }
        
        return generateTableElementAttributes(viewModel)
    }
    
    public func sectionFooterAttributes(tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributes {
        guard let viewModel = footerViewModel(sectionIndex) else {
            Debug.error("Section model with index \(sectionIndex) no has footer model")
            return defaultElementsAttributes
        }
        
        return generateTableElementAttributes(viewModel)
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
        let cell = elementsProvider.cellForViewModel(viewModel)
        
        if let elementAttributesProvider = cell as? TableElementAttributesProvider {
            elementAttributesProvider.bindTableElementAttributes(elementsAttributesCache.cellAttributes(indexPath))
        }
        
        return cell
    }
    
    //UITableViewDelegate
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return elementsAttributesCache.cellAttributes(indexPath).estimatedHeight
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return elementsAttributesCache.sectionHeaderAttributes(section).estimatedHeight
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return elementsAttributesCache.sectionFooterAttributes(section).estimatedHeight
    }
    
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerViewModel = headerViewModel(section) else {
            return nil
        }
        
        let headerView = elementsProvider.viewForViewModel(headerViewModel)
        
        if let elementAttributesProvider = headerView as? TableElementAttributesProvider {
            elementAttributesProvider.bindTableElementAttributes(elementsAttributesCache.sectionHeaderAttributes(section))
        }
        
        return headerView
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerViewModel = footerViewModel(section) else {
            return nil
        }
        
        let footerView = elementsProvider.viewForViewModel(footerViewModel)
        
        if let elementAttributesProvider = footerView as? TableElementAttributesProvider {
            elementAttributesProvider.bindTableElementAttributes(elementsAttributesCache.sectionHeaderAttributes(section))
        }
        
        return footerView
    }
    
    //Other
    
    private func headerViewModel(sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex).headerViewModel
    }
    
    private func footerViewModel(sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex).footerViewModel
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
    
    private func generateTableElementAttributes(viewModel: ViewModelType) -> TableElementAttributes {
        let viewType = elementsProvider.viewTypeForViewModel(viewModel)
        
        guard let elementAttributesProviderType = viewType as? TableElementAttributesProvider.Type else {
            Debug.error("View type \(viewType) for view model \(viewModel.dynamicType) has no implementation for TableElementPresenterType protocol")
            return defaultElementsAttributes
        }
        
        return elementAttributesProviderType.tableElementAttributes(viewModel)
    }
}