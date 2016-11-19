//
//  ModuleBuidler.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class ModuleBuilder<TModulePresenter: UIViewController> where TModulePresenter: ViewPresenterType,
    TModulePresenter.ViewModel: ModuleViewModel {
    public typealias ModulPresenterBuilder = (Void) -> TModulePresenter
    public typealias ViewModelBuilder = (Void) -> TModulePresenter.ViewModel
    public typealias RouterBuilder = (TModulePresenter) -> TModulePresenter.ViewModel.Router
    
    private var modulePresenterBuilder: ModulPresenterBuilder
    private var viewModelBuilder: ViewModelBuilder?
    private var routerBuilder: RouterBuilder?
    
    public init(modulePresenterBuilder: @escaping ModulPresenterBuilder) {
        self.modulePresenterBuilder = modulePresenterBuilder
    }
    
    public func bindViewModel(_ viewModelBuilder: ViewModelBuilder?) {
        self.viewModelBuilder = viewModelBuilder
    }
    
    public func bindRouter(_ routerBuilder: RouterBuilder?) {
        self.routerBuilder = routerBuilder
    }
    
    public func buildModule() -> UIViewController {
        let modulePresenter = modulePresenterBuilder()
        
        let viewModel = viewModelBuilder?()
        
        if let viewModel = viewModel {
            let router = routerBuilder?(modulePresenter)
            
            if let router = router {
                viewModel.bindRouter(router)
            }
            
            modulePresenter.bindViewModel(viewModel)
        }
        
        return modulePresenter
    }
}
