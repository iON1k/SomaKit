//
//  TableElementsProvider.swift
//  SomaKit
//
//  Created by Anton on 26.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class TableElementsProvider: ViewsProvider<UITableView> {
    
}

extension TableElementsProvider {
    public func registerTableElementGenerator<TViewModel: ViewModelType,
                                      TView: UIView where TView: TableElementPresenterType>(elementGenerator: (TViewModel, UITableView) -> TView) {
        _internalRegisterViewGenerator(elementGenerator)
    }
    
    public func registerCellClass<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type, cellType: TCell.Type, reuseId: String? = nil) {
        let normalizedReuseId = normalizeReuseId(reuseId, cellType: cellType)
        context.registerClass(cellType, forCellReuseIdentifier: normalizedReuseId)
        
        registerCellGenerator(viewModelType, cellType: cellType, reuseId: normalizedReuseId)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type, cellType: TCell.Type, nib: UINib, reuseId: String? = nil) -> Void {
        let normalizedReuseId = normalizeReuseId(reuseId, cellType: cellType)
        context.registerNib(nib, forCellReuseIdentifier: normalizedReuseId)
        
        registerCellGenerator(viewModelType, cellType: cellType, reuseId: normalizedReuseId)
    }
    
    public func registerCellNib<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell: NibProviderType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type,
                                                                                               cellType: TCell.Type, reuseId: String? = nil) -> Void {
        registerCellNib(viewModelType, cellType: cellType, nib: cellType.loadNib(), reuseId: reuseId)
    }
    
    public func cellForViewModel<TViewModel: ViewModelType>(viewModel: TViewModel) -> UITableViewCell {
        let generatedView = viewForViewModel(viewModel)
        
        guard let cell = generatedView as? UITableViewCell else {
            Log.error("TableElementsProvider: view for viewModel \(viewModel.dynamicType) wrong type \(generatedView.dynamicType). Expected type UITableViewCell")
            return UITableViewCell()
        }
        
        return cell;
    }
    
    private func registerCellGenerator<TViewModel: ViewModelType, TCell: UITableViewCell
        where TCell: TableElementPresenterType, TCell.ViewModel == TViewModel>(viewModelType: TViewModel.Type, cellType: TCell.Type, reuseId: String) {
        registerTableElementGenerator { (viewModel: TViewModel, tableView) -> TCell in
            guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) else {
                Log.error("Table view dequeue reusable cell with id \(reuseId) failed")
                return TCell()
            }
            
            guard let castedCell = cell as? TCell else {
                Log.error("Table view reusable cell with id \(reuseId) wrong type \(cell.dynamicType). Expected type \(cellType)")
                return TCell()
            }
            
            castedCell.bindViewModel(viewModel)
            
            return castedCell
        }
    }
    
    private func normalizeReuseId(reuseId: String?, cellType: UITableViewCell.Type) -> String {
        return reuseId ?? Utils.typeName(cellType)
    }
}
