//
//  TableViewDataSource.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableViewDataSource: TableViewDataSourceType, TableElementsAttributesCalculatorEngineType {
    public let sectionsModels: [TableViewSectionModel]
    private let elementsProvider: TableElementsProvider

    public init(sectionsModels: [TableViewSectionModel], elementsProvider: TableElementsProvider) {
        self.elementsProvider = elementsProvider
        self.sectionsModels = sectionsModels
    }

    public func calculateCellAttributes(sectionIndex: Int, rowIndex: Int) -> TableElementAttributesType {
        return elementAttributes(for: cellViewModel(sectionIndex: sectionIndex, rowIndex: rowIndex))
    }

    public func calculateSectionHeaderAttributes(sectionIndex: Int) -> TableElementAttributesType {
        guard let viewModel = headerViewModel(sectionIndex: sectionIndex) else {
            Debug.fatalError("Attributes calculation failed: section header view model with index \(sectionIndex) not found")
        }

        return elementAttributes(for: viewModel)
    }

    public func calculateSectionFooterAttributes(sectionIndex: Int) -> TableElementAttributesType {
        guard let viewModel = footerViewModel(sectionIndex: sectionIndex) else {
            Debug.fatalError("Attributes calculation failed: section footer view model with index \(sectionIndex) not found")
        }

        return elementAttributes(for: viewModel)
    }

    public func headerViewModel(sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex: sectionIndex).headerViewModel
    }

    public func footerViewModel(sectionIndex: Int) -> ViewModelType? {
        return sectionModel(sectionIndex: sectionIndex).footerViewModel
    }

    public func cellViewModel(sectionIndex: Int, rowIndex: Int) -> ViewModelType {
        let sectionModel = self.sectionModel(sectionIndex: sectionIndex)

        guard rowIndex < sectionModel.cellsViewModels.count else  {
            Debug.fatalError("Cell view model for index (section: \(sectionIndex), row: \(rowIndex)) not found")
        }

        return sectionModel.cellsViewModels[rowIndex]
    }

    public func rowsCount(sectionIndex: Int) -> Int {
        return sectionModel(sectionIndex: sectionIndex).cellsViewModels.count
    }

    public func sectionsCount() -> Int {
        return sectionsModels.count
    }

    public func view(for viewModel: ViewModelType) -> UIView {
        guard let view = elementsProvider.view(for: viewModel) else {
            Log.error("View for view model type \(type(of: viewModel)) not found")
            return UIView()
        }

        return view
    }

    private func sectionModel(sectionIndex: Int) -> TableViewSectionModel {
        guard sectionIndex < sectionsModels.count else {
            Debug.fatalError("Attributes calculation failed: section model with index \(sectionIndex) not found")
        }

        return sectionsModels[sectionIndex]
    }

    private func elementAttributes(for viewModel: ViewModelType) -> TableElementAttributesType {
        guard let viewType = elementsProvider.viewFactory(for: viewModel)?.viewType else {
            Debug.fatalError("Attributes calculation failed: view factory for view model \(type(of: viewModel)) not found")
        }

        guard let attributedElementType = viewType as? TableAttributedElementType.Type else {
            Debug.fatalError("Attributes calculation failed: view type \(viewType) has no implementation for TableAttributedElementType protocol")
        }

        return attributedElementType.tableElementAttributes(for: viewModel)
    }
}
