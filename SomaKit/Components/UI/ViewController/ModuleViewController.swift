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
    
    open fileprivate(set) var viewModel: ViewModel?
    
    fileprivate let isBindedSubject = BehaviorSubject(value: false)
    fileprivate let isActiveSubject = BehaviorSubject(value: false)
    
    fileprivate let uiBindable: SomaUIBindable
    
    public required init(context: InitContext) {
        uiBindable = SomaUIBindable(isBindedSubject: isBindedSubject, isActiveSubject: isActiveSubject, scheduler: MainScheduler.instance)

        super.init(context: context)
    }
    
    open func bindViewModel(_ viewModel: ViewModel?) {
        let prevViewModel = self.viewModel
        guard prevViewModel != nil || viewModel != nil else {
            return
        }
        
        if prevViewModel != nil {
            _onViewModelWillReseted()
            isBindedSubject.onNext(false)
        }
        
        self.viewModel = viewModel
        
        if let viewModel = viewModel {
            _onViewModelDidUpdated(viewModel)
            tryToBindViewModel()
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tryToBindViewModel()
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
    
    fileprivate func tryToBindViewModel() {
        guard isViewLoaded else {
            return
        }
        
        guard let viewModel = viewModel else {
            return
        }
        
        _onViewModelBind(viewModel)
        isBindedSubject.onNext(true)
    }
    
    open func _onViewModelDidUpdated(_ viewModel: ViewModel) {
        //Nothing
    }
    
    open func _onViewModelWillReseted() {
        //Nothing
    }
    
    open func _onViewModelBind(_ viewModel: ViewModel) {
        //Nothing
    }
    
    open func whileBinded<T>(_ observable: Observable<T>) -> Observable<T> {
        return uiBindable.whileBinded(observable)
    }
    
    open func whileActive<T>(_ observable: Observable<T>) -> Observable<T> {
        return uiBindable.whileActive(observable)
    }
}
