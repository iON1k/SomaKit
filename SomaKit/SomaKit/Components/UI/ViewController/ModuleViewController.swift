//
//  ModuleViewController.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

open class ModuleViewController<TViewModel: ModuleViewModel>: SomaViewController, ViewPresenterType, UiBindableType {
    public typealias ViewModel = TViewModel
    
    open private(set) var viewModel: ViewModel?
    
    private let isBindedSubject = BehaviorSubject(value: false)
    private let isActiveSubject = BehaviorSubject(value: false)
    
    private let uiBindable: SomaUIBindable
    
    public required init(context: InitContext) {
        uiBindable = SomaUIBindable(isBindedSubject: isBindedSubject, isActiveSubject: isActiveSubject, scheduler: MainScheduler.instance)

        super.init(context: context)
    }
    
    public func bindViewModel(_ viewModel: ViewModel?) {
        if self.viewModel != nil {
            isBindedSubject.onNext(false)
        }
        
        self.viewModel = viewModel
        tryToBindUI()
        
        if viewModel != nil {
            isBindedSubject.onNext(true)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tryToBindUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isActiveSubject.onNext(true)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isActiveSubject.onNext(false)
    }
    
    deinit {
        bindViewModel(nil)
    }
    
    private func tryToBindUI() {
        guard isViewLoaded else {
            return
        }
        
        guard let viewModel = viewModel else {
            return
        }
        
        _onBindUI(viewModel)
    }
    
    open func _onBindUI(_ viewModel: ViewModel) {
        //Nothing
    }
    
    public func whileBinded<TObservable : ObservableType>(_ observable: TObservable) -> Observable<TObservable.E> {
        return uiBindable.whileBinded(observable)
    }
    
    public func whileActive<TObservable : ObservableType>(_ observable: TObservable) -> Observable<TObservable.E> {
        return uiBindable.whileActive(observable)
    }
}
