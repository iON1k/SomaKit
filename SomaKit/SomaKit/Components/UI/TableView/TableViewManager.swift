//
//  TableViewManager.swift
//  SomaKit
//
//  Created by Anton on 28.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public typealias TableElementType = ViewModelPresenter & TableElementBehavior

public class TableViewManager: SomaProxy, UITableViewDataSource, UITableViewDelegate, TableElementAttributesCacheSource {
    public let tableView: UITableView
    
    public typealias SectionsModels = [TableViewSectionType]
    public typealias SectionsAttributes = [TableSectionElementsAttributes]
    public typealias UpdatingHandler = (_ tableView: UITableView, _ updatingData: UpdatingData) -> Void
    
    public let elementsProvider: TableElementsProvider
    
    private let elementsAttributesCache = TableElementAttributesCache()
    private let defaultElementsAttributes = TableElementAttributes(prefferedHeight: 10)
    
    private static let defautSectionsData = SectionsModels()
    
    private let updateDataEvents = Variable(UpdatingEvent(sectionsData: defautSectionsData))
    
    open private(set) var showingSectionsData = defautSectionsData
    
    public var actualSectionsData: SectionsModels {
        return updateDataEvents.value.sectionsData
    }
    
    private weak var forwardDelegate: UITableViewDelegate?
    private weak var forwardDataSource: UITableViewDataSource?
    
    public init(tableView: UITableView, elementsGenerators: [ViewGenerator]) {
        self.tableView = tableView
        self.elementsProvider = TableElementsProvider(elementsGenerators: elementsGenerators)
        
        super.init()
        
        elementsAttributesCache.source = self
        
        tableView.rx.setDataSource(self)
            .dispose(whenDeallocated: self)
        
        tableView.rx.setDelegate(self)
            .dispose(whenDeallocated: self)
        
        startObserveUpdatingEvents()
    }
    
    public func bindForwardObject(_ forwardObject: Any?, retain: Bool) {
        Debug.ensureIsMainThread()
        
        forwardDelegate = forwardObject as? UITableViewDelegate
        forwardDataSource = forwardObject as? UITableViewDataSource
        _bindForwardObject(forwardObject, withRetain: retain)
    }
    
    public func resetForwardObject() {
        Debug.ensureIsMainThread()
        
        bindForwardObject(nil, retain: false)
    }
    
    public func updateData(_ event: UpdatingEvent) {
        updateDataEvents <= event
    }
    
    //TableElementAttributesCacheSource
    
    public func cellAttributes(_ tableElementAttributesCache: TableElementAttributesCache, indexPath: IndexPath) -> TableElementAttributesType {
        let viewModel = cellViewModel(indexPath)
        return generateTableElementAttributes(viewModel)
    }
    
    public func sectionHeaderAttributes(_ tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributesType {
        guard let viewModel = headerViewModel(sectionIndex) else {
            Debug.error("Section model with index \(sectionIndex) no has header model")
            return defaultElementsAttributes
        }
        
        return generateTableElementAttributes(viewModel)
    }
    
    public func sectionFooterAttributes(_ tableElementAttributesCache: TableElementAttributesCache, sectionIndex: Int) -> TableElementAttributesType {
        guard let viewModel = footerViewModel(sectionIndex) else {
            Debug.error("Section model with index \(sectionIndex) no has footer model")
            return defaultElementsAttributes
        }
        
        return generateTableElementAttributes(viewModel)
    }
    
    //UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forwardDataSource?.tableView(tableView, numberOfRowsInSection: section)
        return rowsCount(section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        forwardDataSource?.tableView(tableView, cellForRowAt: indexPath)
        
        let viewModel = cellViewModel(indexPath)
        
        let cell = cellForViewModel(viewModel)
        bindAttributes(elementsAttributesCache.cellAttributes(indexPath), view: cell)
        
        return cell
    }
    
    //UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForRowAt: indexPath)
        return elementsAttributesCache.cellAttributes(indexPath).estimatedHeight
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForHeaderInSection: section)
        return elementsAttributesCache.sectionHeaderAttributes(section).estimatedHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForFooterInSection: section)
        return elementsAttributesCache.sectionFooterAttributes(section).estimatedHeight
    }
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForHeaderInSection: section)
        
        guard let headerViewModel = headerViewModel(section) else {
            return nil
        }
        
        let headerView = viewForViewModel(headerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: headerView)
        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        forwardDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        onViewDidEndDisplaying(cell)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
        
        onViewDidEndDisplaying(view)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForFooterInSection: section)
        
        guard let footerViewModel = footerViewModel(section) else {
            return nil
        }
        
        let footerView = viewForViewModel(footerViewModel)
        bindAttributes(elementsAttributesCache.sectionHeaderAttributes(section), view: footerView)
        
        return footerView
    }
    
    //Other
    
    private func headerViewModel(_ sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex).headerViewModel
    }
    
    private func footerViewModel(_ sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex).footerViewModel
    }
    
    private func cellViewModel(_ indexPath: IndexPath) -> ViewModelType {
        return sectionModel((indexPath as NSIndexPath).section).cellsViewModels[(indexPath as NSIndexPath).row]
    }
    
    private func sectionModel(_ sectionIndex: Int) -> TableViewSectionType {
        return showingSectionsData[sectionIndex]
    }
    
    private func rowsCount(_ sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex).cellsViewModels.count
    }
    
    private func sectionsCount() -> Int {
        return showingSectionsData.count
    }

    private func viewForViewModel(_ viewModel: ViewModelType) -> UIView {
        guard let view = elementsProvider.viewForViewModel(viewModel, with: tableView) else {
            Log.error("View for view model type \(type(of: viewModel)) not registered")
            return UIView()
        }

        return view
    }

    private func cellForViewModel(_ viewModel: ViewModelType) -> UITableViewCell {
        guard let cell = elementsProvider.cellForViewModel(viewModel, with: tableView) else {
            Log.error("Cell for view model type \(type(of: viewModel)) not registered")
            return UITableViewCell()
        }

        return cell
    }

    private func beginUpdating(_ updatingEvent: UpdatingEvent, updatingData: UpdatingData) {
        Debug.ensureIsMainThread()
        
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
    
    private func prepareUpdatingDataObserver(_ updatingEvent: UpdatingEvent) -> Observable<UpdatingData> {
        return Observable.create({ (observer) -> Disposable in
            let sectionsData = updatingEvent.sectionsData
            let updatingData = updatingEvent.needPrepareData ? self.prepareUpdatingData(sectionsData) : UpdatingData(sectionsData: sectionsData)
            
            observer.onNext(updatingData)
            observer.onCompleted()
            
            return updatingEvent.disposable
        })
    }
    
    private func prepareUpdatingData(_ sectionsModels: SectionsModels) -> UpdatingData {
        var sectionsAttributes = SectionsAttributes()
        
        for sectionModel in sectionsModels {
            var sectionHeaderAttributes: TableElementAttributesType?
            if let headerViewModel = sectionModel.headerViewModel {
                sectionHeaderAttributes = generateTableElementAttributes(headerViewModel)
            }
            
            var sectionFooterAttributes: TableElementAttributesType?
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
    
    private func generateTableElementAttributes(_ viewModel: ViewModelType) -> TableElementAttributesType {
        let viewType = elementsProvider.viewGenerator(for: viewModel)?.viewType
        
        guard let elementBehaviorType = viewType as? TableElementBehavior.Type else {
            Debug.error("View type \(viewType) for view model \(type(of: viewModel)) has no implementation for TableElementType protocol")
            return defaultElementsAttributes
        }
        
        return elementBehaviorType.tableElementAttributes(viewModel)
    }
    
    private func onViewDidEndDisplaying(_ view: UIView) {
        TableElementBehavior(view)?.tableElementReset()
    }
    
    private func bindAttributes(_ attributes: TableElementAttributesType, view: UIView) {
        TableElementBehavior(view)?.bindTableElementAttributes(attributes)
    }
    
    private func TableElementBehavior(_ view: UIView) -> TableElementBehavior? {
        guard let TableElementBehavior = view as? TableElementBehavior else {
            Debug.error("View type \(type(of: view)) not implemented TableElementBehavior protocol")
            return nil
        }
        
        return TableElementBehavior
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
        
        init(sectionsData: [TableViewSectionType], needPrepareData: Bool = true, updatingHandler: @escaping UpdatingHandler = UpdatingEvent.defaultUpdatingHandler) {
            self.sectionsData = sectionsData
            self.needPrepareData = needPrepareData
            self.updatingHandler = updatingHandler
        }
        
        public static func defaultUpdatingHandler(_ tableView: UITableView, updatingData: UpdatingData) {
            tableView.reloadData()
        }
    }
}
