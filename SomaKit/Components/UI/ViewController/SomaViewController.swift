//
//  SomaViewController.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class SomaViewController: UIViewController {
    public enum InitContext {
        case NibName(nibNameOrNil: String?, nibBundleOrNil: NSBundle?)
        case Coder(aDecoder: NSCoder)
    }
    
    public convenience override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.init(context: .NibName(nibNameOrNil: nibNameOrNil, nibBundleOrNil: nibBundleOrNil))
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(context: .Coder(aDecoder: aDecoder))
    }
    
    //https://theswiftdev.com/2015/08/05/swift-init-patterns
    public required init(context: InitContext) {
        switch context {
        case .NibName(let nibNameOrNil, let nibBundleOrNil):
            super.init(nibName: nibNameOrNil, bundle:nibBundleOrNil)
        case .Coder(let aDecoder):
            super.init(coder: aDecoder)!
        }
    }
}
