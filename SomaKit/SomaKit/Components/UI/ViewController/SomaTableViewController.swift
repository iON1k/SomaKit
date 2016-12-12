//
//  SomaTableViewController.swift
//  SomaKit
//
//  Created by Anton on 04.09.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class SomaTableViewController<TViewModel: ContentViewModelType>: SomaContentViewController<TViewModel> {
    public private(set) var _tableManager: TableViewManager!

    open var _tableView: UITableView! {
        return nil
    }

    open override var _contentView: UIView? {
        return _tableView
    }

    open override func _onBindUI(viewModel: TViewModel) {
        super._onBindUI(viewModel: viewModel)
        
        _tableManager = TableViewManager(tableView: _tableView, elementsFactories: [])
    }
}
