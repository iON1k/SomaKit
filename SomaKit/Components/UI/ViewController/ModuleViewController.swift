//
//  ModuleViewController.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public class ModuleViewController<TViewModel: ModuleViewModel>: SomaViewController, ViewPresenterType, UiBindableType {
    public typealias ViewModel = TViewModel
    
    public private(set) var viewModel: ViewModel?
    
    private let isBindedSubject = BehaviorSubject(value: false)
    private let isActiveSubject = BehaviorSubject(value: false)
    
    private let uiBindable: SomaUIBindable
    
    public required init(context: InitContext) {
        uiBindable = SomaUIBindable(isBindedSubject: isBindedSubject, isActiveSubject: isActiveSubject, scheduler: MainScheduler.instance)

        super.init(context: context)
    }
    
    public func bindViewModel(viewModel: ViewModel?) {
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tryToBindViewModel()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isActiveSubject.onNext(true)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        isActiveSubject.onNext(false)
    }
    
    deinit {
        bindViewModel(nil)
    }
    
    private func tryToBindViewModel() {
        guard isViewLoaded() else {
            return
        }
        
        guard let viewModel = viewModel else {
            return
        }
        
        _onViewModelBind(viewModel)
        isBindedSubject.onNext(true)
    }
    
    public func _onViewModelDidUpdated(viewModel: ViewModel) {
        //Nothing
    }
    
    public func _onViewModelWillReseted() {
        //Nothing
    }
    
    public func _onViewModelBind(viewModel: ViewModel) {
        //Nothing
    }
    
    public func onBinded<T>(observable: Observable<T>) -> Observable<T> {
        return uiBindable.onBinded(observable)
    }
    
    public func onActive<T>(observable: Observable<T>) -> Observable<T> {
        return uiBindable.onActive(observable)
    }
}
