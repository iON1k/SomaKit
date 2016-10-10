//
//  AbstractTableViewController.swift
//  SomaKit
//
//  Created by Anton on 04.09.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public typealias TableBehaviorModuleViewModel = protocol<ModuleViewModel, TableViewBehaviorProvider>

public class AbstractTableViewController<TViewModel: TableBehaviorModuleViewModel>: ModuleViewController<TViewModel> {
    public var _tableManager: TableViewManager!
    private var refreshControl: UIRefreshControl!
    
    public var _tableView: UITableView {
        Utils.abstractMethod()
    }
    
    public override func _onViewModelBind(viewModel: ViewModel) {
        super._onViewModelBind(viewModel)
        
        let tableManager = TableViewManager(tableView: _tableView)
        let tableBehavior = viewModel.tableBehavior
        
        tableManager.bindDataSource(
            tableBehavior.sectionModels
            .whileBinded(self)
        )
        
        _ = tableBehavior.isDataLoading
            .whileBinded(self)
            .doOnNext(_showActivityIndicator)
            .subscribe()
        
        if _supportPullToRefresh() {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(beginRefreshing), forControlEvents: .ValueChanged)
            _tableView.addSubview(refreshControl)
            self.refreshControl = refreshControl
        }
        
        _tableManager = tableManager
    }
    
    public func _showActivityIndicator(show: Bool) {
        Utils.abstractMethod()
    }
    
    public func _supportPullToRefresh() -> Bool {
        return false
    }
    
    @objc private func beginRefreshing() {
        _ = viewModel?.tableBehavior
            .beginRefreshData()
            .whileBinded(self)
            .doOnNext(refreshControl.endRefreshing)
            .subscribe()
    }
}