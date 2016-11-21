//
//  AbstractTableViewController.swift
//  SomaKit
//
//  Created by Anton on 04.09.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public typealias TableBehaviorModuleViewModel = ModuleViewModel & TableViewBehaviorProvider

open class AbstractTableViewController<TViewModel: TableBehaviorModuleViewModel>: ModuleViewController<TViewModel> {
    public var _tableManager: TableViewManager!
    private var refreshControl: UIRefreshControl!
    
    open var _tableView: UITableView {
        Debug.abstractMethod()
    }
    
    open override func _onBindUI(_ viewModel: ViewModel) {
        super._onBindUI(viewModel)
        
        let tableManager = TableViewManager(tableView: _tableView)
        let tableBehavior = viewModel.tableBehavior
        
        _ = tableManager.bindDataSource(
            tableBehavior.sectionModels
            .whileBinded(self)
        )
        
        _ = tableBehavior.isDataLoading
            .whileBinded(self)
            .do(onNext: _showActivityIndicator)
            .subscribe()
        
        if _supportPullToRefresh() {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(beginRefreshing), for: .valueChanged)
            _tableView.addSubview(refreshControl)
            self.refreshControl = refreshControl
        }
        
        _tableManager = tableManager
    }
    
    open func _showActivityIndicator(_ show: Bool) {
        Debug.abstractMethod()
    }
    
    open func _supportPullToRefresh() -> Bool {
        return false
    }
    
    @objc private func beginRefreshing() {
        _ = viewModel?.tableBehavior
            .beginRefreshData()
            .whileBinded(self)
            .do(onNext: refreshControl.endRefreshing)
            .subscribe()
    }
}
