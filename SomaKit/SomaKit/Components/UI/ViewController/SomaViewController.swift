//
//  SomaViewController.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class SomaViewController<TViewModel: ViewModelType>: UIViewController {
    open private(set) var _viewModel: TViewModel
    
    public init(viewModel: TViewModel) {
        _viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        Debug.fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        _onCreateViews()
        _onBindUI(viewModel: _viewModel)
    }

    open func _onCreateViews() {
        //Nothing
    }

    open func _onBindUI(viewModel: TViewModel) {
        //Nothing
    }
}
