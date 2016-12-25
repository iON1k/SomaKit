//
//  TableViewProxy.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol TableViewDataSourceType {
    func headerViewModel(sectionIndex: Int) -> TableElementViewModel?

    func footerViewModel(sectionIndex: Int) -> TableElementViewModel?

    func cellViewModel(sectionIndex: Int, rowIndex: Int) -> TableElementViewModel

    func rowsCount(sectionIndex: Int) -> Int

    func sectionsCount() -> Int

    func loadElementView(for viewModel: TableElementViewModel, with tableView: UITableView) -> UIView?
}

public class TableViewProxy: SomaProxy, UITableViewDataSource, UITableViewDelegate {
    private var attributesCalculator: TableElementsAttributesCalculatorType
    private var dataSource: TableViewDataSourceType

    private let tableView: UITableView

    private weak var forwardDelegate: UITableViewDelegate?
    private weak var forwardDataSource: UITableViewDataSource?

    public init(tableView: UITableView, dataSource: TableViewDataSourceType, attributesCalculator: TableElementsAttributesCalculatorType) {
        self.tableView = tableView
        self.dataSource = dataSource
        self.attributesCalculator = attributesCalculator

        super.init()

        tableView.rx.setDataSource(self)
            .dispose(whenDeallocated: self)

        tableView.rx.setDelegate(self)
            .dispose(whenDeallocated: self)
    }

    public override func setForwardObject(_ forwardObject: Any!, withRetain retain: Bool) {
        super.setForwardObject(forwardObject, withRetain: retain)

        forwardDelegate = forwardObject as? UITableViewDelegate
        forwardDataSource = forwardObject as? UITableViewDataSource
    }

    public func update(dataSource: TableViewDataSourceType, attributesCalculator: TableElementsAttributesCalculatorType, updatingHandler: (UITableView) -> Void) {
        Debug.ensureIsMainThread()

        self.dataSource = dataSource
        self.attributesCalculator = attributesCalculator
        updatingHandler(tableView)
    }

    //UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sectionsCount()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        forwardDataSource?.tableView(tableView, numberOfRowsInSection: section)
        return dataSource.rowsCount(sectionIndex: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        forwardDataSource?.tableView(tableView, cellForRowAt: indexPath)

        let viewModel = dataSource.cellViewModel(sectionIndex: indexPath.section, rowIndex: indexPath.row)

        guard let cell = loadElement(tableView: tableView, viewModel: viewModel, attributes:
            attributesCalculator.cellAttributes(sectionIndex: indexPath.section, rowIndex: indexPath.row)) as? UITableViewCell else {
            Log.error("Cell for view model type \(type(of: viewModel)) not found")
            return UITableViewCell()
        }

        return cell
    }

    //UITableViewDelegate

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForRowAt: indexPath)
        return attributesCalculator.cellAttributes(sectionIndex: indexPath.section, rowIndex: indexPath.row).estimatedHeight
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForHeaderInSection: section)
        return attributesCalculator.sectionHeaderAttributes(sectionIndex: section).estimatedHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        _ = forwardDelegate?.tableView?(tableView, heightForFooterInSection: section)
        return attributesCalculator.sectionFooterAttributes(sectionIndex: section).estimatedHeight
    }


    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForHeaderInSection: section)

        guard let headerViewModel = dataSource.headerViewModel(sectionIndex: section) else {
            return nil
        }

        guard let headerView = loadElement(tableView: tableView, viewModel: headerViewModel, attributes: attributesCalculator.sectionHeaderAttributes(sectionIndex: section)) else {
            return nil
        }

        return headerView
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForFooterInSection: section)

        guard let footerViewModel = dataSource.footerViewModel(sectionIndex: section) else {
            return nil
        }

        guard let footerView = loadElement(tableView: tableView, viewModel: footerViewModel, attributes: attributesCalculator.sectionHeaderAttributes(sectionIndex: section)) else {
            return nil
        }

        return footerView
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        forwardDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)

        resetViewModel(for: cell)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)

        resetViewModel(for: view)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        forwardDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)

        resetViewModel(for: view)
    }

    private func resetViewModel(for elementView: UIView) {
        guard let elementPresenter = elementView as? UnsafeTableElementPresenter else {
            return
        }

        elementPresenter.resetViewModel()
    }

    private func loadElement(tableView: UITableView, viewModel: TableElementViewModel, attributes: TableElementAttributesType) -> UIView? {
        guard let elementView = dataSource.loadElementView(for: viewModel, with: tableView) else {
            Log.error("Table element view for view model type \(type(of: viewModel)) not found")
            return nil
        }

        if let elementPresenter = elementView as? UnsafeTableElementPresenter {
            elementPresenter.unsafeBindViewModel(viewModel: viewModel)
        } else {
            Log.error("Table element view \(type(of: viewModel)) has no implementation for UnsafeTableElementPresenter protocol")
        }

        if let attributedElementType = elementView as? TableAttributedElementType {
            attributedElementType.bindTableElementAttributes(with: attributes)
        } else {
            Debug.error("View type \(type(of: elementView)) not implemented TableElementBehavior protocol")
        }

        return elementView

    }
}
