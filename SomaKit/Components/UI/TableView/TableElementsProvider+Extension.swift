//
//  TableElementsProvider+Extension.swift
//  SomaKit
//
//  Created by Anton on 08.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

extension TableElementsProvider {
    public func cellForViewModel(_ viewModel: ViewModelType) -> UITableViewCell {
        let generatedView = viewForViewModel(viewModel)
        
        guard let cell = generatedView as? UITableViewCell else {
            Log.error("TableElementsProvider: view for viewModel \(type(of: viewModel)) wrong type \(type(of: generatedView)). Expected type UITableViewCell")
            return UITableViewCell()
        }
        
        return cell;
    }
    
    public func registerCellClass<TViewModel: ViewModelType, TCell: UITableViewCell>(_ viewModelType: TViewModel.Type, cellType: TCell.Type,
                                                                               reuseId: String? = nil, cellFactory: @escaping (Void) -> TCell? = SomaFunc.justNil)
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: cellType)
        context.register(cellType, forCellReuseIdentifier: normalizedReuseId)
        
        registerCellReuseGenerator(viewModelType, cellType: cellType, reuseId: normalizedReuseId, cellFactory: cellFactory)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TCell: UITableViewCell>(_ viewModelType: TViewModel.Type, cellType: TCell.Type, nib: UINib,
                                                                               reuseId: String? = nil, cellFactory: @escaping (Void) -> TCell? = SomaFunc.justNil) -> Void
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: cellType)
        context.register(nib, forCellReuseIdentifier: normalizedReuseId)
        
        registerCellReuseGenerator(viewModelType, cellType: cellType, reuseId: normalizedReuseId, cellFactory: cellFactory)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TCell: UITableViewCell>(_ viewModelType: TViewModel.Type,
                                                                                                       cellType: TCell.Type, reuseId: String? = nil) -> Void
        where TCell: TableElementPresenterType, TCell: NibProviderType, TCell.ViewModel == TViewModel {
        registerCellNib(viewModelType, cellType: cellType, nib: cellType.loadNib(), reuseId: reuseId)
    }
    
    fileprivate func registerCellReuseGenerator<TViewModel: ViewModelType, TCell: UITableViewCell>(_ viewModelType: TViewModel.Type, cellType: TCell.Type, reuseId: String, cellFactory: @escaping (Void) -> TCell?)
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel {
        registerViewReuseGenerator(viewModelType, viewType: cellType, reuseId: reuseId, viewFactory: cellFactory) { (tableView, reuseId) -> UIView? in
            return tableView.dequeueReusableCell(withIdentifier: reuseId)
        }
    }
    
    public func registerHeaderFooterClass<TViewModel: ViewModelType, TView: UIView>(_ viewModelType: TViewModel.Type, viewType: TView.Type,
                                                                               reuseId: String? = nil, viewFactory: @escaping (Void) -> TView? = SomaFunc.justNil)
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: viewType)
        context.register(viewType, forHeaderFooterViewReuseIdentifier: normalizedReuseId)
        
        registerHeaderFooterReuseGenerator(viewModelType, viewType: viewType, reuseId: normalizedReuseId, viewFactory: viewFactory)
    }
    
    public func registerHeaderFooterNib<TViewModel: ViewModelType, TView: UIView>(_ viewModelType: TViewModel.Type, viewType: TView.Type, nib: UINib,
                                                                               reuseId: String? = nil, viewFactory: @escaping (Void) -> TView? = SomaFunc.justNil) -> Void
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel {
        let normalizedReuseId = normalizeReuseId(reuseId, viewType: viewType)
        context.register(nib, forHeaderFooterViewReuseIdentifier: normalizedReuseId)
        
        registerHeaderFooterReuseGenerator(viewModelType, viewType: viewType, reuseId: normalizedReuseId, viewFactory: viewFactory)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TView: UIView>(_ viewModelType: TViewModel.Type,
                                                                                                       viewType: TView.Type, reuseId: String? = nil) -> Void
        where TView: TableElementPresenterType, TView: NibProviderType, TView.ViewModel == TViewModel {
        registerHeaderFooterNib(viewModelType, viewType: viewType, nib: viewType.loadNib(), reuseId: reuseId)
    }
    
    fileprivate func registerHeaderFooterReuseGenerator<TViewModel: ViewModelType, TView: UIView>(_ viewModelType: TViewModel.Type, viewType: TView.Type,
                                                                               reuseId: String, viewFactory: @escaping (Void) -> TView?)
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel {
        registerViewReuseGenerator(viewModelType, viewType: viewType, reuseId: reuseId, viewFactory: viewFactory) { (tableView, reuseId) -> UIView? in
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseId)
        }
    }
    
    fileprivate func registerViewReuseGenerator<TViewModel: ViewModelType, TView: UIView>(_ viewModelType: TViewModel.Type, viewType: TView.Type,
                                                                               reuseId: String, viewFactory: @escaping (Void) -> TView?, reuseIdFactory: @escaping (UITableView, String) -> UIView?)
        where TView: TableElementPresenterType, TView.ViewModel == TViewModel {
        registerTableElementGenerator { (viewModel: TViewModel, tableView) -> TView in
            guard let view = viewFactory() ?? reuseIdFactory(tableView, reuseId) else {
                Log.error("Table view dequeue reusable view with id \(reuseId) failed")
                return TView()
            }
            
            guard let castedView = view as? TView else {
                Log.error("Table view reusable view with id \(reuseId) wrong type \(type(of: view)). Expected type \(viewType)")
                return TView()
            }
            
            castedView.bindViewModel(viewModel)
            
            return castedView
        }
    }
    
    fileprivate func normalizeReuseId(_ reuseId: String?, viewType: UIView.Type) -> String {
        return reuseId ?? Utils.typeName(viewType)
    }
}
