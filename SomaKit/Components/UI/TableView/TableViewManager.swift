//
//  TableViewManager.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

open class TableViewManager: SomaProxy, UITableViewDataSource, UITableViewDelegate, TableElementAttributesCacheSource {
    open let tableView: UITableView
    
    public typealias SectionsModels = [TableViewSectionModel]
    public typealias SectionsAttributes = [TableSectionElementsAttributes]
    public typealias UpdatingHandler = (_ tableView: UITableView, _ updatingData: UpdatingData) -> Void
    
    open let elementsProvider: TableElementsProvider
    
    fileprivate let elementsAttributesCache = TableElementAttributesCache()
    fileprivate let defaultElementsAttributes = DefaultTableElementAttributes(prefferedHeight: 10)
    
    fileprivate static let defautSectionsData = SectionsModels()
    
    fileprivate let updateDataEvents = Variable(UpdatingEvent(sectionsData: defautSectionsData))
    
    open fileprivate(set) var showingSectionsData = defautSectionsData
    
    open var actualSectionsData: SectionsModels {
        return updateDataEvents.value.sectionsData
    }
    
    fileprivate weak var forwardDelegate: UITableViewDelegate?
    fileprivate weak var forwardDataSource: UITableViewDataSource?
    
    public init(tableView: UITableView) {
        self.tableView = tableView
        elementsProvider = TableElementsProvider(tableView: tableView)
        
        super.init()
        
        elementsAttributesCache.source = self
        
        tableView.rx.setDataSource(self)
            .dispose(whenDeallocated: self)
        
        tableView.rx.setDelegate(self)
            .dispose(whenDeallocated: self)
        
        startObserveUpdatingEvents()
    }
    
    open func bindForwardObject(_ forwardObject: Any?, retain: Bool) {
        Utils.ensureIsMainThread()
        
        forwardDelegate = forwardObject as? UITableViewDelegate
        forwardDataSource = forwardObject as? UITableViewDataSource
        _bindForwardObject(forwardObject, withRetain: retain)
    }
    
    open func resetForwardObject() {
        Utils.ensureIsMainThread()
        
        bindForwardObject(nil, retain: false)
    }
    
    open func updateData(_ event: UpdatingEvent) {
        updateDataEvents <= event
    }
    
    //TableElementAttributesCacheSource
    
    open func cellAttributes(_ tableElementAttributesCache: TableElementAttributesCache, indexPath: IndexPath) -> TableElementAttributes {
        let viewModel = cellViewModel(indexPath)
        return generateTableElementAttributes(viewModel)
    }
    
    open func sectionHeaderAttributes(_ tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributes {
        guard let viewModel = headerViewModel(sectionIndex) else {
            Debug.error("Section model with index \(sectionIndex) no has header model")
            return defaultElementsAttributes
        }
        
        return generateTableElementAttributes(viewModel)
    }
    
    open func sectionFooterAttributes(_ tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributes {
        guard let viewModel = footerViewModel(sectionIndex) else {
            Debug.error("Section model with index \(sectionIndex) no has footer model")
            return defaultElementsAttributes
        }
        
        return generateTableElementAttributes(viewModel)
    }
    
    //UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forwardDataSource?.tableView(tableView, numberOfRowsInSection: section)
        return rowsCount(section)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        forwardDataSource?.tableView(tableView, cellForRowAt: indexPath)
        
        let viewModel = cellViewModel(indexPath)
        
        let cell = elementsProvider.cellForViewModel(viewModel)
        bindAttributes(elementsAttributesCache.cellAttributes(indexPath), view: cell)
        
        return cell
    }
    
    //UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForRowAt: indexPath)
        return elementsAttributesCache.cellAttributes(indexPath).estimatedHeight
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForHeaderInSection: section)
        return elementsAttributesCache.sectionHeaderAttributes(section).estimatedHeight
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForFooterInSection: section)
        return elementsAttributesCache.sectionFooterAttributes(section).estimatedHeight
    }
    
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForHeaderInSection: section)
        
        guard let headerViewModel = headerViewModel(section) else {
            return nil
        }
        
        let headerView = elementsProvider.viewForViewModel(headerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: headerView)
        
        return headerView
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        forwardDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        onViewDidEndDisplaying(cell)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForFooterInSection: section)
        
        guard let footerViewModel = footerViewModel(section) else {
            return nil
        }
        
        let footerView = elementsProvider.viewForViewModel(footerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: footerView)
        
        return footerView
    }
    
    //Other
    
    fileprivate func headerViewModel(_ sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex).headerViewModel
    }
    
    fileprivate func footerViewModel(_ sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex).footerViewModel
    }
    
    fileprivate func cellViewModel(_ indexPath: IndexPath) -> ViewModelType {
        return sectionModel((indexPath as NSIndexPath).section).cellsViewModels[(indexPath as NSIndexPath).row]
    }
    
    fileprivate func sectionModel(_ sectionIndex: Int) -> TableViewSectionModel {
        return showingSectionsData[sectionIndex]
    }
    
    fileprivate func rowsCount(_ sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex).cellsViewModels.count
    }
    
    fileprivate func sectionsCount() -> Int {
        return showingSectionsData.count
    }
    
    fileprivate func beginUpdating(_ updatingEvent: UpdatingEvent, updatingData: UpdatingData) {
        Utils.ensureIsMainThread()
        
        if updatingEvent.disposable.isDisposed {
            return
        }
        
        showingSectionsData = updatingData.sectionsData
        if let sectionsAttributes = updatingData.sectionsAttributes {
            elementsAttributesCache.resetCacheWithPreloadedData(sectionsAttributes)
        } else {
            elementsAttributesCache.invalidateCache()
        }
        
        updatingEvent.updatingHandler(tableView, updatingData)
    }
    
    fileprivate func prepareUpdatingDataObserver(_ updatingEvent: UpdatingEvent) -> Observable<UpdatingData> {
        return Observable.create({ (observer) -> Disposable in
            let sectionsData = updatingEvent.sectionsData
            let updatingData = updatingEvent.needPrepareData ? self.prepareUpdatingData(sectionsData) : UpdatingData(sectionsData: sectionsData)
            
            observer.onNext(updatingData)
            observer.onCompleted()
            
            return updatingEvent.disposable
        })
    }
    
    fileprivate func prepareUpdatingData(_ sectionsModels: SectionsModels) -> UpdatingData {
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
            for (index, cellModel) in sectionModel.cellsViewModels.enumerated() {
                cellsAttributes[index] = generateTableElementAttributes(cellModel)
            }
            
            let sectionAttributes = TableSectionElementsAttributes(cellsAttributes: cellsAttributes,
                                                                   headerAttributes: sectionHeaderAttributes, footerAttributes: sectionFooterAttributes)
            
            sectionsAttributes.append(sectionAttributes)
        }
        
        return UpdatingData(sectionsData: sectionsModels, sectionsAttributes: sectionsAttributes)
    }
    
    fileprivate func generateTableElementAttributes(_ viewModel: ViewModelType) -> TableElementAttributes {
        let viewType = elementsProvider.viewTypeForViewModel(viewModel)
        
        guard let elementBehaviorType = viewType as? TableElementBehavior.Type else {
            Debug.error("View type \(viewType) for view model \(type(of: viewModel)) has no implementation for TableElementPresenterType protocol")
            return defaultElementsAttributes
        }
        
        return elementBehaviorType.tableElementAttributes(viewModel)
    }
    
    fileprivate func onViewDidEndDisplaying(_ view: UIView) {
        tableElementBehavior(view)?.tableElementReset()
    }
    
    fileprivate func bindAttributes(_ attributes: TableElementAttributes, view: UIView) {
        tableElementBehavior(view)?.bindTableElementAttributes(attributes)
    }
    
    fileprivate func tableElementBehavior(_ view: UIView) -> TableElementBehavior? {
        guard let tableElementBehavior = view as? TableElementBehavior else {
            Debug.error("View type \(type(of: view)) not implemented TableElementBehavior protocol")
            return nil
        }
        
        return tableElementBehavior
    }
    
    fileprivate func startObserveUpdatingEvents() {
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
            .do(onNext: { [weak self] (updatingEvent, updatingData) in
                self?.beginUpdating(updatingEvent, updatingData: updatingData)
            })
            .takeUntil(rx.deallocated)
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
        
        init(sectionsData: [TableViewSectionModel], needPrepareData: Bool = true, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
            self.sectionsData = sectionsData
            self.needPrepareData = needPrepareData
            self.updatingHandler = updatingHandler
        }
        
        public static func defaultUpdatingHandler(_ tableView: UITableView, updatingData: UpdatingData) {
            tableView.reloadData()
        }
    }
}
