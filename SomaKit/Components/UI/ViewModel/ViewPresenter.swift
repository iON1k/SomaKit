//
//  ViewPresenter.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ViewPresenterType {
    associatedtype ViewModel: ViewModelType
    
    func bindViewModel(viewModel: ViewModel?)
}
