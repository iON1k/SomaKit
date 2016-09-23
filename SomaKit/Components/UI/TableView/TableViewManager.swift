//
//  TableViewManager.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public class TableViewManager: SomaProxy, UITableViewDataSource, UITableViewDelegate, TableElementAttributesCacheSource {
    public let tableView: UITableView
    
    public typealias SectionsModels = [TableViewSectionModel]
    public typealias SectionsAttributes = [TableSectionElementsAttributes]
    public typealias UpdatingHandler = (tableView: UITableView, updatingData: UpdatingData) -> Void
    
    public let elementsProvider: TableElementsProvider
    
    private let elementsAttributesCache = TableElementAttributesCache()
    private let defaultElementsAttributes = DefaultTableElementAttributes(prefferedHeight: 10)
    
    private static let defautSectionsData = SectionsModels()
    
    private let updateDataEvents = Variable(UpdatingEvent(sectionsData: defautSectionsData))
    
    public private(set) var showingSectionsData = defautSectionsData
    
    public var actualSectionsData: SectionsModels {
        return updateDataEvents.value.sectionsData
    }
    
    private weak var forwardDelegate: UITableViewDelegate?
    private weak var forwardDataSource: UITableViewDataSource?
    
    public init(tableView: UITableView) {
        self.tableView = tableView
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
    
    public func updateData(event: UpdatingEvent) {
        updateDataEvents <= event
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
        return showingSectionsData[sectionIndex]
    }
    
    private func rowsCount(sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex).cellsViewModels.count
    }
    
    private func sectionsCount() -> Int {
        return showingSectionsData.count
    }
    
    private func beginUpdating(updatingEvent: UpdatingEvent, updatingData: UpdatingData) {
        Utils.ensureIsMainThread()
        
        if updatingEvent.disposable.disposed {
            return
        }
        
        showingSectionsData = updatingData.sectionsData
        if let sectionsAttributes = updatingData.sectionsAttributes {
            elementsAttributesCache.resetCacheWithPreloadedData(sectionsAttributes)
        } else {
            elementsAttributesCache.invalidateCache()
        }
        
        updatingEvent.updatingHandler(tableView: tableView, updatingData: updatingData)
    }
    
    private func prepareUpdatingDataObserver(updatingEvent: UpdatingEvent) -> Observable<UpdatingData> {
        return Observable.create({ (observer) -> Disposable in
            let sectionsData = updatingEvent.sectionsData
            let updatingData = updatingEvent.needPrepareData ? self.prepareUpdatingData(sectionsData) : UpdatingData(sectionsData: sectionsData)
            
            observer.onNext(updatingData)
            observer.onCompleted()
            
            return updatingEvent.disposable
        })
    }
    
    private func prepareUpdatingData(sectionsModels: SectionsModels) -> UpdatingData {
        var sectionsAttributes = SectionsAttributes()
        
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
    
    private func startObserveUpdatingEvents() {
        _ = updateDataEvents.asObservable()
            .skip(1)
            .map({ [weak self] (updatingEvent) -> Observable<(UpdatingEvent, UpdatingData)> in
                guard let strongSelf = self else {
                    return Observable.empty()
                }
                
                return strongSelf.prepareUpdatingDataObserver(updatingEvent)
                    .map({ (updatingData) -> (UpdatingEvent, UpdatingData) in
                        return (updatingEvent, updatingData)
                    })
            })
            .concat()
            .observeOnMainScheduler()
            .doOnNext({ [weak self] (updatingEvent, updatingData) in
                self?.beginUpdating(updatingEvent, updatingData: updatingData)
            })
            .takeUntil(rx_deallocated)
            .subscribe()
    }
    
    public struct UpdatingData {
        public let sectionsData: SectionsModels
        public let sectionsAttributes: SectionsAttributes?
        
        init(sectionsData: SectionsModels, sectionsAttributes: SectionsAttributes? = nil) {
            self.sectionsData = sectionsData
            self.sectionsAttributes = sectionsAttributes
        }
    }
    
    public struct UpdatingEvent {
        public let sectionsData: SectionsModels
        public let needPrepareData: Bool
        public let updatingHandler: UpdatingHandler
        public let disposable = BooleanDisposable()
        
        init(sectionsData: [TableViewSectionModel], needPrepareData: Bool = true, updatingHandler: UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
            self.sectionsData = sectionsData
            self.needPrepareData = needPrepareData
            self.updatingHandler = updatingHandler
        }
        
        public static func defaultUpdatingHandler(tableView: UITableView, updatingData: UpdatingData) {
            tableView.reloadData()
        }
    }
}