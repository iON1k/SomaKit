//
//  TableElementsProvider+Extension.swift
//  SomaKit
//
//  Created by Anton on 08.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

extension TableElementsProvider {
    public func cellForViewModel(viewModel: ViewModelType) -> UITableViewCell {
        let generatedView = viewForViewModel(viewModel)
        
        guard let cell = generatedView as? UITableViewCell else {
            Log.error("TableElementsProvider: view for viewModel \(viewModel.dynamicType) wrong type \(generatedView.dynamicType). Expected type UITableViewCell")
            return UITableViewCell()
        }
        
        return cell;
    }
    
    public func registerCellClass<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type, cellType: TCell.Type,
                                                                               reuseId: String? = nil, cellFactory: Void -> TCell? = SomaFunc.justNil) {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: cellType)
        context.registerClass(cellType, forCellReuseIdentifier: normalizedReuseId)
        
        registerCellReuseGenerator(viewModelType, cellType: cellType, reuseId: normalizedReuseId, cellFactory: cellFactory)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type, cellType: TCell.Type, nib: UINib,
                                                                               reuseId: String? = nil, cellFactory: Void -> TCell? = SomaFunc.justNil) -> Void {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: cellType)
        context.registerNib(nib, forCellReuseIdentifier: normalizedReuseId)
        
        registerCellReuseGenerator(viewModelType, cellType: cellType, reuseId: normalizedReuseId, cellFactory: cellFactory)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell: NibProviderType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type,
                                                                                                       cellType: TCell.Type, reuseId: String? = nil) -> Void {
        registerCellNib(viewModelType, cellType: cellType, nib: cellType.loadNib(), reuseId: reuseId)
    }
    
    private func registerCellReuseGenerator<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type, cellType: TCell.Type, reuseId: String, cellFactory: Void -> TCell?) {
        registerViewReuseGenerator(viewModelType, viewType: cellType, reuseId: reuseId, viewFactory: cellFactory) { (tableView, reuseId) -> UIView? in
            return tableView.dequeueReusableCellWithIdentifier(reuseId)
        }
    }
    
    public func registerHeaderFooterClass<TViewModel: ViewModelType, TView: UIView
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel>(viewModelType: TViewModel.Type, viewType: TView.Type,
                                                                               reuseId: String? = nil, viewFactory: Void -> TView? = SomaFunc.justNil) {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: viewType)
        context.registerClass(viewType, forHeaderFooterViewReuseIdentifier: normalizedReuseId)
        
        registerHeaderFooterReuseGenerator(viewModelType, viewType: viewType, reuseId: normalizedReuseId, viewFactory: viewFactory)
    }
    
    public func registerHeaderFooterNib<TViewModel: ViewModelType, TView: UIView
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel>(viewModelType: TViewModel.Type, viewType: TView.Type, nib: UINib,
                                                                               reuseId: String? = nil, viewFactory: Void -> TView? = SomaFunc.justNil) -> Void {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: viewType)
        context.registerNib(nib, forHeaderFooterViewReuseIdentifier: normalizedReuseId)
        
        registerHeaderFooterReuseGenerator(viewModelType, viewType: viewType, reuseId: normalizedReuseId, viewFactory: viewFactory)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TView: UIView
        where TView: TableElementPresenterType, TView: NibProviderType, TView.ViewModel == TViewModel>(viewModelType: TViewModel.Type,
                                                                                                       viewType: TView.Type, reuseId: String? = nil) -> Void {
        registerHeaderFooterNib(viewModelType, viewType: viewType, nib: viewType.loadNib(), reuseId: reuseId)
    }
    
    private func registerHeaderFooterReuseGenerator<TViewModel: ViewModelType, TView: UIView
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel>(viewModelType: TViewModel.Type, viewType: TView.Type,
                                                                               reuseId: String, viewFactory: Void -> TView?) {
        registerViewReuseGenerator(viewModelType, viewType: viewType, reuseId: reuseId, viewFactory: viewFactory) { (tableView, reuseId) -> UIView? in
            return tableView.dequeueReusableHeaderFooterViewWithIdentifier(reuseId)
        }
    }
    
    private func registerViewReuseGenerator<TViewModel: ViewModelType, TView: UIView
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel>(viewModelType: TViewModel.Type, viewType: TView.Type,
                                                                               reuseId: String, viewFactory: Void -> TView?, reuseIdFactory: (UITableView, String) -> UIView?) {
        registerTableElementGenerator { (viewModel: TViewModel, tableView) -> TView in
            guard let view = viewFactory() ?? reuseIdFactory(tableView, reuseId) else {
                Log.error("Table view dequeue reusable view with id \(reuseId) failed")
                return TView()
            }
            
            guard let castedView = view as? TView else {
                Log.error("Table view reusable view with id \(reuseId) wrong type \(view.dynamicType). Expected type \(viewType)")
                return TView()
            }
            
            castedView.bindViewModel(viewModel)
            
            return castedView
        }
    }
    
    private func normalizeReuseId(reuseId: String?, viewType: UIView.Type) -> String {
        return reuseId ?? Utils.typeName(viewType)
    }
}
