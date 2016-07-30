//
//  TableViewWrapper.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public class TableViewWrapper: SomaProxy, UITableViewDataSource, UITableViewDelegate, TableElementAttributesCacheSource {
    public let tableView: UITableView
    
    public typealias ForwardObjectType = protocol<UITableViewDataSource, UITableViewDelegate>
    
    public typealias SectionsModels = [TableViewSectionModel]
    
    private let elementsAttributesCache = TableElementAttributesCache()
    private let elementsProvider: TableElementsProvider
    
    private let defaultElementsAttributes = DefaultTableElementAttributes(prefferedHeight: 10)
    
    private let preparingSectionsModels = Variable(SectionsModels())
    private let sectionsModels = Variable(SectionsModels())
    
    private weak var forwardObject: ForwardObjectType?
    
    private let tableViewUpdatingTimeInterval = 0.1
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        elementsProvider = TableElementsProvider(tableView: tableView)
        
        super.init()
        
        elementsAttributesCache.source = self
        
        tableView.rx_delegate.setForwardToDelegate(self, retainDelegate: false)
        tableView.rx_dataSource.setForwardToDelegate(self, retainDelegate: false)
        
        _ = preparingSectionsModels.asObservable()
            .skip(1)
            .takeUntil(rx_deallocated)
            .flatMapLatest({ [weak self] (sectionsModels) -> Observable<SectionsModels> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                
                return strongSelf.prepareSectionDataObservable(sectionsModels)
            })
            .throttle(tableViewUpdatingTimeInterval, scheduler: ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
            .observeOn(MainScheduler.instance)
            .bindTo(sectionsModels)
        
        _ = sectionsModels.asObservable()
            .doOnNext({ [weak self] (_) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.onSectionsDataDidUpdated()
            })
            .takeUntil(rx_deallocated)
            .subscribe()
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
        return dataSource.bindTo(preparingSectionsModels)
    }
    
    public func reloadDataAsync(sectionsModels: SectionsModels) {
        preparingSectionsModels.value = sectionsModels
    }
    
    public func reloadDataAsync() {
        reloadDataAsync(sectionsModels.value)
    }
    
    public func reloadData(sectionsModels: SectionsModels) {
        Utils.ensureIsMainThread()
        
        self.sectionsModels.value = sectionsModels
        elementsAttributesCache.invalidateCache()
        
        onSectionsDataDidUpdated()
    }
    
    public func reloadData() {
        reloadData(sectionsModels.value)
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
        return currentSections()[sectionIndex]
    }
    
    private func rowsCount(sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex).cellsViewModels.count
    }
    
    private func sectionsCount() -> Int {
        return currentSections().count
    }
    
    private func currentSections() -> SectionsModels {
        return sectionsModels.value
    }
    
    private func onSectionsDataDidUpdated() {
        Utils.ensureIsMainThread()
        
        tableView.reloadData()
    }
    
    private func prepareSectionDataObservable(sectionsModels: SectionsModels) -> Observable<SectionsModels> {
        //TODO: ???
        return Observable.just(sectionsModels)
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
}