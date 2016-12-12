//
//  TableHeaderFooterFactory.swift
//  SomaKit
//
//  Created by Anton on 11.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableHeaderFooterFactory: TableElementBaseFactrory {
    public init<TView: UIView>(viewModelType: TView.ViewModel.Type, viewType: TView.Type) where TView: ViewModelPresenter {
        super.init(viewModelType: viewModelType, viewType: viewType, registerHandler: { (tableView, reuseId) in
            tableView.register(viewType, forCellReuseIdentifier: reuseId)
        }, dequeueHandler: { (tableView, reuseId) in
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseId)
        })
    }
}
