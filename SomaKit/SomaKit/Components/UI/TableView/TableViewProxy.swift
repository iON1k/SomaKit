//
//  TableViewProxy.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol TableViewDataSourceType {
    func headerViewModel(sectionIndex: Int) -> ViewModelType?

    func footerViewModel(sectionIndex: Int) -> ViewModelType?

    func cellViewModel(sectionIndex: Int, rowIndex: Int) -> ViewModelType

    func rowsCount(sectionIndex: Int) -> Int

    func sectionsCount() -> Int

    func view(for viewModel: ViewModelType) -> UIView
}

public class TableViewProxy: SomaProxy, UITableViewDataSource, UITableViewDelegate {
    public private(set) var attributesCalculator: TableElementsAttributesCalculatorType
    public private(set) var dataSource: TableViewDataSourceType

    private weak var forwardDelegate: UITableViewDelegate?
    private weak var forwardDataSource: UITableViewDataSource?

    public init(dataSource: TableViewDataSourceType, attributesCalculator: TableElementsAttributesCalculatorType) {
        self.dataSource = dataSource
        self.attributesCalculator = attributesCalculator
    }

    public override func setForwardObject(_ forwardObject: Any!, withRetain retain: Bool) {
        super.setForwardObject(forwardObject, withRetain: retain)

        forwardDelegate = forwardObject as? UITableViewDelegate
        forwardDataSource = forwardObject as? UITableViewDataSource
    }

    public func updateWith(dataSource: TableViewDataSourceType, attributesCalculator: TableElementsAttributesCalculatorType) {
        self.dataSource = dataSource
        self.attributesCalculator = attributesCalculator
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

        guard let cell = dataSource.view(for: viewModel) as? UITableViewCell else {
            Log.error("Cell for view model type \(type(of: viewModel)) not found")
            return UITableViewCell()
        }

        bindAttributes(attributesCalculator.cellAttributes(sectionIndex: indexPath.section, rowIndex: indexPath.row), view: cell)

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

        let headerView = dataSource.view(for: headerViewModel)
        bindAttributes(attributesCalculator.sectionHeaderAttributes(sectionIndex: section), view: headerView)

        return headerView
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        _ = forwardDelegate?.tableView?(tableView, viewForFooterInSection: section)

        guard let footerViewModel = dataSource.footerViewModel(sectionIndex: section) else {
            return nil
        }

        let footerView = dataSource.view(for: footerViewModel)
        bindAttributes(attributesCalculator.sectionHeaderAttributes(sectionIndex: section), view: footerView)

        return footerView
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

    private func onViewDidEndDisplaying(_ view: UIView) {
        tableElementBehavior(with: view)?.tableElementReset()
    }

    private func bindAttributes(_ attributes: TableElementAttributesType, view: UIView) {
        tableElementBehavior(with: view)?.bindTableElementAttributes(attributes)
    }

    private func tableElementBehavior(with view: UIView) -> TableElementBehavior? {
        guard let tableElementBehavior = view as? TableElementBehavior else {
            Debug.error("View type \(type(of: view)) not implemented TableElementBehavior protocol")
            return nil
        }

        return tableElementBehavior
    }
}
