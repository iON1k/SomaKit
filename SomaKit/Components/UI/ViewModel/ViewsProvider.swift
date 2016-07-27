//
//  ViewsProvider.swift
//  SomaKit
//
//  Created by Anton on 27.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class ViewsProvider<TContext> {
    public typealias ViewGenerator = (ViewModelType, TContext) -> UIView
    
    public let context: TContext
    
    private var registeredViewsGenerators = [String : ViewGenerator]()
    
    public init(context: TContext) {
        self.context = context
    }
    
    public func registerViewGenerator<TViewModel: ViewModelType>(viewModelType: TViewModel.Type, viewGenerator: (TViewModel, TContext) -> UIView) {
        _registerViewGenerator(viewGeneratorKey(viewModelType)) { (viewModel, context) -> UIView in
            guard let castedViewModel = viewModel as? TViewModel else {
                Log.error("ViewsProvider: view model wrong type \(viewModel.dynamicType). Expected type \(viewModelType)")
                return UIView()
            }
            
            return viewGenerator(castedViewModel, context)
        }
    }
    
    public func viewForViewModel<TViewModel: ViewModelType>(viewModel: TViewModel) -> UIView {
        let generatorKey = viewGeneratorKey(TViewModel)
        guard let viewGenerator = registeredViewsGenerators[generatorKey] else {
            Log.error("ViewsProvider: view generator with key \(generatorKey) not registered")
            return UIView()
        }
        
        return viewGenerator(viewModel, context)
    }
    
    private func _registerViewGenerator(viewKey: String, viewGenerator: ViewGenerator) {
        Utils.ensureIsMainThread()
        
        guard registeredViewsGenerators[viewKey] == nil else {
            Log.error("ViewsProvider: view generator with key \(viewKey) already registered")
            return
        }
        
        registeredViewsGenerators[viewKey] = viewGenerator
    }
    
    private func viewGeneratorKey(viewModelType: ViewModelType.Type) -> String {
        return Utils.typeName(viewModelType)
    }
}
