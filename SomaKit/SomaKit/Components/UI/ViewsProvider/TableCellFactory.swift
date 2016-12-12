//
//  TableCellFactory.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableCellFactory: TableElementBaseFactrory {
    public init<TCell: UITableViewCell>(viewModelType: TCell.ViewModel.Type, cellType: TCell.Type) where TCell: ViewModelPresenter {
        super.init(viewModelType: viewModelType, viewType: cellType, registerHandler: { (tableView, reuseId) in
            tableView.register(cellType, forCellReuseIdentifier: reuseId)
        }, dequeueHandler: { (tableView, reuseId) in
            return tableView.dequeueReusableCell(withIdentifier: reuseId)
        })
    }
}
