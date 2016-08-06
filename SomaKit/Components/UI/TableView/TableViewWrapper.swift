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
    
    public typealias SectionsModels = [TableViewSectionModel]
    public typealias UpdatingHandler = (tableView: UITableView) -> Void
    
    public let elementsAttributesCache = TableElementAttributesCache()
    public let elementsProvider: TableElementsProvider
    
    private let defaultElementsAttributes = DefaultTableElementAttributes(prefferedHeight: 10)
    
    private let updateDataEvents = Variable(UpdatingEvent(sectionsData: SectionsModels(), asyncUpdating: false, updatingHandler: TableViewWrapper.reloadTable))
    private var sectionsModels = SectionsModels()
    
    private let updatingHandler: UpdatingHandler
    
    private weak var forwardDelegate: UITableViewDelegate?
    private weak var forwardDataSource: UITableViewDataSource?
    
    public convenience init(tableView: UITableView) {
        self.init(tableView: tableView, updatingHandler: TableViewWrapper.reloadTable)
    }
    
    public init(tableView: UITableView, updatingHandler: UpdatingHandler) {
        self.tableView = tableView
        self.updatingHandler = updatingHandler
        elementsProvider = TableElementsProvider(tableView: tableView)
        
        super.init()
        
        elementsAttributesCache.source = self
        
        tableView.rx_delegate.setForwardToDelegate(self, retainDelegate: false)
        tableView.rx_dataSource.setForwardToDelegate(self, retainDelegate: false)
        
        startObserveUpdatingEvents()
    }
    
    public func bindForwardObject(forwardObject: AnyObject?, retain: Bool) {
        Utils.ensureIsMainThread()
        
        forwardDelegate = forwardObject as? UITableViewDelegate
        forwardDataSource = forwardObject as? UITableViewDataSource
        _bindForwardObject(forwardObject, withRetain: retain)
    }
    
    public func resetForwardObject() {
        Utils.ensureIsMainThread()
        
        bindForwardObject(nil, retain: false)
    }
    
    public func bindDataSource(dataSource: Observable<SectionsModels>) -> Disposable {
        return dataSource.map({ (sectionsData) -> UpdatingEvent in
            return UpdatingEvent(sectionsData: sectionsData, asyncUpdating: true, updatingHandler: self.updatingHandler)
        })
        .bindTo(updateDataEvents)
    }
    
    public func updateDataAsync(sectionsModels: SectionsModels, updatingHandler: UpdatingHandler) {
        updateSectionsData(sectionsModels, asyncUpdating: true, updatingHandler: updatingHandler)
    }
    
    public func updateData(sectionsModels: SectionsModels, updatingHandler: UpdatingHandler) {
        updateSectionsData(sectionsModels, asyncUpdating: false, updatingHandler: updatingHandler)
    }
    
    public func reloadDataAsync(sectionsModels: SectionsModels) {
        reloadSectionsData(sectionsModels, asyncUpdating: true)
    }
    
    public func reloadDataAsync() {
        reloadDataAsync(sectionsModels)
    }
    
    public func reloadData(sectionsModels: SectionsModels) {
        Utils.ensureIsMainThread()
        reloadSectionsData(sectionsModels, asyncUpdating: false)
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
        forwardDataSource?.tableView(tableView, numberOfRowsInSection: section)
        return rowsCount(section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        forwardDataSource?.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        let viewModel = cellViewModel(indexPath)
        
        let cell = elementsProvider.cellForViewModel(viewModel)
        bindAttributes(elementsAttributesCache.cellAttributes(indexPath), view: cell)
        
        return cell
    }
    
    //UITableViewDelegate
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        forwardDelegate?.tableView?(tableView, heightForRowAtIndexPath: indexPath)
        return elementsAttributesCache.cellAttributes(indexPath).estimatedHeight
    }

    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        forwardDelegate?.tableView?(tableView, heightForHeaderInSection: section)
        return elementsAttributesCache.sectionHeaderAttributes(section).estimatedHeight
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        forwardDelegate?.tableView?(tableView, heightForFooterInSection: section)
        return elementsAttributesCache.sectionFooterAttributes(section).estimatedHeight
    }
    
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        forwardDelegate?.tableView?(tableView, viewForHeaderInSection: section)
        
        guard let headerViewModel = headerViewModel(section) else {
            return nil
        }
        
        let headerView = elementsProvider.viewForViewModel(headerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: headerView)
        
        return headerView
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
        
        onViewDidEndDisplaying(cell)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        forwardDelegate?.tableView?(tableView, viewForFooterInSection: section)
        
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
    
    private func beginUpdating(updatingEvent: UpdatingEvent, updatingData: UpdatingData) {
        Utils.ensureIsMainThread()
        
        sectionsModels = updatingData.sectionsData
        if let sectionsAttributes = updatingData.sectionsAttributes {
            elementsAttributesCache.resetCacheWithPreloadedData(sectionsAttributes)
        } else {
            elementsAttributesCache.invalidateCache()
        }
        
        updatingEvent.updatingHandler(tableView: tableView)
    }
    
    private func prepareUpdatingDataBackgroundObservable(sectionsModels: SectionsModels) -> Observable<UpdatingData> {
        return Observable.deferred({ () -> Observable<UpdatingData> in
                return Observable.just(self.prepareUpdatingData(sectionsModels))
            })
            .subcribeOnBackgroundScheduler()
    }
    
    private func prepareUpdatingData(sectionsModels: SectionsModels) -> UpdatingData {
        var sectionsAttributes = [TableSectionElementsAttributes]()
        
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
            
            sectionsAttributes.append(sectionAttributes)
        }
        
        return UpdatingData(sectionsData: sectionsModels, sectionsAttributes: sectionsAttributes)
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
    
    private func reloadSectionsData(sectionsModels: SectionsModels, asyncUpdating: Bool) {
        updateSectionsData(sectionsModels, asyncUpdating: asyncUpdating, updatingHandler: TableViewWrapper.reloadTable)
    }
    
    private func updateSectionsData(sectionsModels: SectionsModels, asyncUpdating: Bool, updatingHandler: UpdatingHandler) {
        updateDataEvents.value = UpdatingEvent(sectionsData: sectionsModels, asyncUpdating: asyncUpdating, updatingHandler: updatingHandler)
    }
    
    private func startObserveUpdatingEvents() {
        _ = updateDataEvents.asObservable()
            .skip(1)
            .flatMapLatest({ [weak self] (updatingEvent) -> Observable<(UpdatingEvent, UpdatingData)> in
                let sectionsData = updatingEvent.sectionsData
                
                
                if updatingEvent.asyncUpdating {
                    guard let strongSelf = self else {
                        return Observable.empty()
                    }
                    
                    let updatingEventObservable = Observable.just(updatingEvent)
                    let updatingDataObservable = strongSelf.prepareUpdatingDataBackgroundObservable(sectionsData)
                    return Observable.combineLatest(updatingEventObservable, updatingDataObservable, resultSelector: { (event, data) -> (UpdatingEvent, UpdatingData) in
                        return (event, data)
                    })
                } else {
                    let updatingData = UpdatingData(sectionsData: sectionsData)
                    return Observable.just((updatingEvent, updatingData))
                }
                })
            .observeOnMainScheduler()
            .doOnNext({ [weak self] (updatingEvent, updatingData) in
                self?.beginUpdating(updatingEvent, updatingData: updatingData)
                })
            .takeUntil(rx_deallocated)
            .subscribe()
    }
    
    private static func reloadTable(tableView: UITableView) {
        tableView.reloadData()
    }
    
    private struct UpdatingData {
        let sectionsData: [TableViewSectionModel]
        let sectionsAttributes: [TableSectionElementsAttributes]?
        
        init(sectionsData: [TableViewSectionModel], sectionsAttributes: [TableSectionElementsAttributes]? = nil) {
            self.sectionsData = sectionsData
            self.sectionsAttributes = sectionsAttributes
        }
    }
    
    private struct UpdatingEvent {
        let sectionsData: SectionsModels
        let asyncUpdating: Bool
        let updatingHandler: UpdatingHandler
    }
}