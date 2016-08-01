//
//  TableViewWrapper.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

private struct PreparedSectionsData {
    let sectionsData: [TableViewSectionModel]
    let preparedSectionsAttributes: [TableSectionElementsAttributes]?
    
    init(sectionsData: [TableViewSectionModel], preparedSectionsAttributes: [TableSectionElementsAttributes]? = nil) {
        self.sectionsData = sectionsData
        self.preparedSectionsAttributes = preparedSectionsAttributes
    }
}

public class TableViewWrapper: SomaProxy, UITableViewDataSource, UITableViewDelegate, TableElementAttributesCacheSource {
    public let tableView: UITableView
    
    public typealias ForwardObjectType = protocol<UITableViewDataSource, UITableViewDelegate>
    
    public typealias SectionsModels = [TableViewSectionModel]
    public typealias UpdateDataEvent = (sections: SectionsModels, async: Bool)
    
    private let elementsAttributesCache = TableElementAttributesCache()
    private let elementsProvider: TableElementsProvider
    
    private let defaultElementsAttributes = DefaultTableElementAttributes(prefferedHeight: 10)
    
    private let updateDataEvents = Variable(UpdateDataEvent(sections: SectionsModels(), async: false))
    private var sectionsModels = SectionsModels()
    
    private weak var forwardObject: ForwardObjectType?
    
    public init(tableView: UITableView, setupElementsProviderHandler: TableElementsProvider -> Void) {
        self.tableView = tableView
        elementsProvider = TableElementsProvider(tableView: tableView)
        
        super.init()
        
        elementsAttributesCache.source = self
        
        tableView.rx_delegate.setForwardToDelegate(self, retainDelegate: false)
        tableView.rx_dataSource.setForwardToDelegate(self, retainDelegate: false)
        
        _ = updateDataEvents.asObservable()
            .skip(1)
            .flatMapLatest({ [weak self] (sectionsModels, async) -> Observable<PreparedSectionsData> in
                if async {
                    guard let strongSelf = self else {
                        return Observable.empty()
                    }
                    
                    return strongSelf.prepareSectionsDataBackgroundObservable(sectionsModels)
                } else {
                    return Observable.just(PreparedSectionsData(sectionsData: sectionsModels))
                }
            })
            .observeOnMainScheduler()
            .doOnNext({ [weak self] (preparedData) in
                self?.updateSectionsData(preparedData)
            })
            .takeUntil(rx_deallocated)
            .subscribe()
        
        setupElementsProviderHandler(elementsProvider)
    }
    
    public func bindForwardObject(forwardObject: ForwardObjectType?, retain: Bool) {
        Utils.ensureIsMainThread()
        
        self.forwardObject = forwardObject
        _bindForwardObject(forwardObject, withRetain: retain)
    }
    
    public func resetForwardObject() {
        Utils.ensureIsMainThread()
        
        bindForwardObject(nil, retain: false)
    }
    
    public func bindDataSource(dataSource: Observable<SectionsModels>) -> Disposable {
        return dataSource.map({ (sectionsData) -> UpdateDataEvent in
            return UpdateDataEvent(sections: sectionsData, async: true)
        })
        .bindTo(updateDataEvents)
    }
    
    public func reloadDataAsync(sectionsModels: SectionsModels) {
        _reloadData(sectionsModels, async: true)
    }
    
    public func reloadDataAsync() {
        reloadDataAsync(sectionsModels)
    }
    
    public func reloadData(sectionsModels: SectionsModels) {
        Utils.ensureIsMainThread()
        _reloadData(sectionsModels, async: false)
    }
    
    public func reloadData() {
        reloadData(sectionsModels)
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
        forwardObject?.tableView(tableView, numberOfRowsInSection: section)
        return rowsCount(section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        forwardObject?.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        let viewModel = cellViewModel(indexPath)
        
        let cell = elementsProvider.cellForViewModel(viewModel)
        bindAttributes(elementsAttributesCache.cellAttributes(indexPath), view: cell)
        
        return cell
    }
    
    //UITableViewDelegate
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        forwardObject?.tableView?(tableView, heightForRowAtIndexPath: indexPath)
        return elementsAttributesCache.cellAttributes(indexPath).estimatedHeight
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        forwardObject?.tableView?(tableView, heightForHeaderInSection: section)
        return elementsAttributesCache.sectionHeaderAttributes(section).estimatedHeight
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        forwardObject?.tableView?(tableView, heightForFooterInSection: section)
        return elementsAttributesCache.sectionFooterAttributes(section).estimatedHeight
    }
    
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        forwardObject?.tableView?(tableView, viewForHeaderInSection: section)
        
        guard let headerViewModel = headerViewModel(section) else {
            return nil
        }
        
        let headerView = elementsProvider.viewForViewModel(headerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: headerView)
        
        return headerView
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        forwardObject?.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
        
        onViewDidEndDisplaying(cell)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        forwardObject?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        forwardObject?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        forwardObject?.tableView?(tableView, viewForFooterInSection: section)
        
        guard let footerViewModel = footerViewModel(section) else {
            return nil
        }
        
        let footerView = elementsProvider.viewForViewModel(footerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: footerView)
        
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
        return sectionsModels[sectionIndex]
    }
    
    private func rowsCount(sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex).cellsViewModels.count
    }
    
    private func sectionsCount() -> Int {
        return sectionsModels.count
    }
    
    private func updateSectionsData(sectionsData: SectionsModels) {
        updateSectionsData(PreparedSectionsData(sectionsData: sectionsData))
    }
    
    private func updateSectionsData(preparedData: PreparedSectionsData) {
        Utils.ensureIsMainThread()
        
        sectionsModels = preparedData.sectionsData
        if let preparedSectionsAttributes = preparedData.preparedSectionsAttributes {
            elementsAttributesCache.resetCacheWithPreloadedData(preparedSectionsAttributes)
        } else {
            elementsAttributesCache.invalidateCache()
        }
        
        tableView.reloadData()
    }
    
    private func prepareSectionsDataBackgroundObservable(sectionsModels: SectionsModels) -> Observable<PreparedSectionsData> {
        return Observable.deferred({ () -> Observable<PreparedSectionsData> in
                return Observable.just(self.prepareSectionsData(sectionsModels))
            })
            .subcribeOnBackgroundScheduler()
    }
    
    private func prepareSectionsData(sectionsModels: SectionsModels) -> PreparedSectionsData {
        var preparedSectionsAttributes = [TableSectionElementsAttributes]()
        
        for sectionModel in sectionsModels {
            var sectionHeaderAttributes: TableElementAttributes?
            if let headerViewModel = sectionModel.headerViewModel {
                sectionHeaderAttributes = generateTableElementAttributes(headerViewModel)
            }
            
            var sectionFooterAttributes: TableElementAttributes?
            if let footerViewModel = sectionModel.footerViewModel {
                sectionFooterAttributes = generateTableElementAttributes(footerViewModel)
            }
            
            var cellsAttributes = CellsAttributes()
            for (index, cellModel) in sectionModel.cellsViewModels.enumerate() {
                cellsAttributes[index] = generateTableElementAttributes(cellModel)
            }
            
            let sectionAttributes = TableSectionElementsAttributes(cellsAttributes: cellsAttributes,
                                                                   headerAttributes: sectionHeaderAttributes, footerAttributes: sectionFooterAttributes)
            
            preparedSectionsAttributes.append(sectionAttributes)
        }
        
        return PreparedSectionsData(sectionsData: sectionsModels, preparedSectionsAttributes: preparedSectionsAttributes)
    }
    
    private func generateTableElementAttributes(viewModel: ViewModelType) -> TableElementAttributes {
        let viewType = elementsProvider.viewTypeForViewModel(viewModel)
        
        guard let elementBehaviorType = viewType as? TableElementBehavior.Type else {
            Debug.error("View type \(viewType) for view model \(viewModel.dynamicType) has no implementation for TableElementPresenterType protocol")
            return defaultElementsAttributes
        }
        
        return elementBehaviorType.tableElementAttributes(viewModel)
    }
    
    private func onViewDidEndDisplaying(view: UIView) {
        tableElementBehavior(view)?.tableElementReset()
    }
    
    private func bindAttributes(attributes: TableElementAttributes, view: UIView) {
        tableElementBehavior(view)?.bindTableElementAttributes(attributes)
    }
    
    private func tableElementBehavior(view: UIView) -> TableElementBehavior? {
        guard let tableElementBehavior = view as? TableElementBehavior else {
            Debug.error("View type \(view.dynamicType) not implemented TableElementBehavior protocol")
            return nil
        }
        
        return tableElementBehavior
    }
    
    private func _reloadData(sectionsModels: SectionsModels, async: Bool) {
        updateDataEvents.value = UpdateDataEvent(sections: sectionsModels, async: async)
    }
}