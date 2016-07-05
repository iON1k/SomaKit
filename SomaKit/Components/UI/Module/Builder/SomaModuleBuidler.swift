//
//  SomaModuleBuidler.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public final class SomaModuleBuidler<TModulePresenter: UIViewController where TModulePresenter: ViewPresenterType,
    TModulePresenter.ViewModel: ModuleViewModel>: ModuleBuidler {
    public typealias ModulPresenterBuilder = Void -> TModulePresenter
    public typealias ViewModelBuilder = Void -> TModulePresenter.ViewModel
    public typealias InteractorBuilder = Void -> TModulePresenter.ViewModel.Interactor
    public typealias RouterBuilder = Void -> TModulePresenter.ViewModel.Router
    
    private var modulePresenterBuilder: ModulPresenterBuilder
    private var viewModelBuilder: ViewModelBuilder?
    private var interactorBuilder: InteractorBuilder?
    private var routerBuilder: RouterBuilder?
    
    public init(modulePresenterBuilder: ModulPresenterBuilder) {
        self.modulePresenterBuilder = modulePresenterBuilder
    }
    
    public func bindViewModel(viewModelBuilder: ViewModelBuilder?) {
        self.viewModelBuilder = viewModelBuilder
    }
    
    public func bindRouter(routerBuilder: RouterBuilder?) {
        self.routerBuilder = routerBuilder
    }
    
    public func bindInteractor(interactorBuilder: InteractorBuilder?) {
        self.interactorBuilder = interactorBuilder
    }
    
    public func buildModule() -> UIViewController {
        let modulePresenter = modulePresenterBuilder()
        
        let viewModel = viewModelBuilder?()
        
        if let viewModel = viewModel {
            let router = routerBuilder?()
            router?.bindTransitionHandler(modulePresenter)
            viewModel.bindRouter(router)
            
            let interactor = interactorBuilder?()
            viewModel.bindInteractor(interactor)
            
            modulePresenter.bindViewModel(viewModel)
        }
        
        return modulePresenter
    }
}
