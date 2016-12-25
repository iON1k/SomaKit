//
//  TableCellFactory.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableCellFactory: TableElementBaseFactory {
    public init<TViewModel: TableElementViewModel, TCell: UITableViewCell>(viewModelType: TViewModel.Type, cellType: TCell.Type, viewModelTypeId: String? = nil)
        where TCell: TableElementType, TViewModel == TCell.ViewModel {
            super.init(viewModelType: viewModelType, elementType: cellType, viewModelTypeId: viewModelTypeId)
    }

    public override func registerElement(tableView: UITableView) {
        tableView.register(elementType, forCellReuseIdentifier: reuseId)
    }

    public override func createElement(tableView: UITableView) -> UIView {
        let cellReuseId = reuseId
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId) else {
            Debug.fatalError("UITableView didn't registered cell with reuseId \(cellReuseId)")
        }

        return cell
    }
}
