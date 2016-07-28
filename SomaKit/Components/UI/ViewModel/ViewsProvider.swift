//
//  ViewsProvider.swift
//  SomaKit
//
//  Created by Anton on 27.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class ViewsProvider<TContext> {
    public typealias ViewGenerator = (ViewModelType, TContext) -> UIView
    public typealias ViewData = (viewType: UIView.Type, viewGenerator: ViewGenerator)
    
    public let context: TContext
    
    private var registeredViewsData = [String : ViewData]()
    
    private let emptyViewData = ViewData(UIView.self) { (viewModel, context) -> UIView in
        return UIView()
    }
    
    public init(context: TContext) {
        self.context = context
    }
    
    public func _internalRegisterViewGenerator<TViewModel: ViewModelType, TView: UIView>(viewGenerator: (TViewModel, TContext) -> TView) {
        registerViewGenerator(viewGeneratorKey(TViewModel), viewType: TView.self) { (viewModel, context) -> UIView in
            guard let castedViewModel = viewModel as? TViewModel else {
                Log.error("ViewsProvider: view model wrong type \(viewModel.dynamicType). Expected type \(TViewModel.self)")
                return UIView()
            }
            
            return viewGenerator(castedViewModel, context)
        }
    }
    
    public func viewForViewModel<TViewModel: ViewModelType>(viewModel: TViewModel) -> UIView {
        return viewDataForViewModel(viewModel).viewGenerator(viewModel, context)
    }
    
    public func viewTypeForViewModel<TViewModel: ViewModelType>(viewModel: TViewModel) -> UIView.Type {
        return viewDataForViewModel(viewModel).viewType
    }
    
    private func viewDataForViewModel<TViewModel: ViewModelType>(viewModel: TViewModel) -> ViewData {
        let generatorKey = viewGeneratorKey(TViewModel)
        guard let viewData = registeredViewsData[generatorKey] else {
            Log.error("ViewsProvider: view data with key \(generatorKey) not registered")
            return emptyViewData
        }
        
        return viewData
    }
    
    private func registerViewGenerator(viewKey: String, viewType: UIView.Type, viewGenerator: ViewGenerator) {
        Utils.ensureIsMainThread()
        
        guard registeredViewsData[viewKey] == nil else {
            Log.error("ViewsProvider: view generator with key \(viewKey) already registered")
            return
        }
        
        registeredViewsData[viewKey] = ViewData(viewType, viewGenerator)
    }
    
    private func viewGeneratorKey(viewModelType: ViewModelType.Type) -> String {
        return Utils.typeName(viewModelType)
    }
}
