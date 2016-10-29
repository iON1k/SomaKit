//
//  ViewsProvider.swift
//  SomaKit
//
//  Created by Anton on 27.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class ViewsProvider<TContext> {
    public typealias ViewGenerator = (ViewModelType, TContext) -> UIView
    public typealias ViewData = (viewType: UIView.Type, viewGenerator: ViewGenerator)
    
    open let context: TContext
    
    private var registeredViewsData = [String : ViewData]()
    private let syncLock = SyncLock()
    
    private let emptyViewData = ViewData(UIView.self) { (viewModel, context) -> UIView in
        return UIView()
    }
    
    public init(context: TContext) {
        self.context = context
    }
    
    open func _internalRegisterViewGenerator<TViewModel: ViewModelType, TView: UIView>(_ viewGenerator: @escaping (TViewModel, TContext) -> TView) {
        registerViewGenerator(viewGeneratorKey(TViewModel.self), viewType: TView.self) { (viewModel, context) -> UIView in
            guard let castedViewModel = viewModel as? TViewModel else {
                Log.error("ViewsProvider: view model wrong type \(type(of: viewModel)). Expected type \(TViewModel.self)")
                return UIView()
            }
            
            return viewGenerator(castedViewModel, context)
        }
    }
    
    open func viewForViewModel(_ viewModel: ViewModelType) -> UIView {
        return viewDataForViewModel(viewModel).viewGenerator(viewModel, context)
    }
    
    open func viewTypeForViewModel(_ viewModel: ViewModelType) -> UIView.Type {
        return viewDataForViewModel(viewModel).viewType
    }
    
    private func viewDataForViewModel(_ viewModel: ViewModelType) -> ViewData {
        return syncLock.sync {
            return unsafeViewDataForViewModel(viewModel)
        }
    }
    
    private func unsafeViewDataForViewModel(_ viewModel: ViewModelType) -> ViewData {
        let generatorKey = viewGeneratorKey(type(of: viewModel))
        guard let viewData = registeredViewsData[generatorKey] else {
            Log.error("ViewsProvider: view data with key \(generatorKey) not registered")
            return emptyViewData
        }
        
        return viewData
    }
    
    private func registerViewGenerator(_ viewKey: String, viewType: UIView.Type, viewGenerator: @escaping ViewGenerator) {
        syncLock.sync {
            unsafeRegisterViewGenerator(viewKey, viewType: viewType, viewGenerator: viewGenerator)
        }
    }
    
    private func unsafeRegisterViewGenerator(_ viewKey: String, viewType: UIView.Type, viewGenerator: @escaping ViewGenerator) {
        guard registeredViewsData[viewKey] == nil else {
            Log.error("ViewsProvider: view generator with key \(viewKey) already registered")
            return
        }
        
        registeredViewsData[viewKey] = ViewData(viewType, viewGenerator)
    }
    
    private func viewGeneratorKey(_ viewModelType: ViewModelType.Type) -> String {
        return Utils.typeName(viewModelType)
    }
}
