//
//  SomaViewController.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

open class SomaViewController: UIViewController {
    public enum InitContext {
        case nibName(nibNameOrNil: String?, nibBundleOrNil: Bundle?)
        case coder(aDecoder: NSCoder)
    }
    
    public convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init(context: .nibName(nibNameOrNil: nibNameOrNil, nibBundleOrNil: nibBundleOrNil))
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(context: .coder(aDecoder: aDecoder))
    }
    
    //https://theswiftdev.com/2015/08/05/swift-init-patterns
    public required init(context: InitContext) {
        switch context {
        case .nibName(let nibNameOrNil, let nibBundleOrNil):
            super.init(nibName: nibNameOrNil, bundle:nibBundleOrNil)
        case .coder(let aDecoder):
            super.init(coder: aDecoder)!
        }
    }
}
