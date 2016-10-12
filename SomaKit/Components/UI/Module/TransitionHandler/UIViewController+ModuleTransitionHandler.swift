//
//  UIViewController+ModuleTransitionHandler.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

extension UIViewController: ModuleTransitionHandler {
    
}

extension ModuleTransitionHandler where Self: UIViewController {
    public func openModule(_ module: UIViewController, transition: (UIViewController, UIViewController) -> Void) {
        transition(self, module)
    }
    
    public func closeModule(_ transition: (UIViewController) -> Void) {
        transition(self)
    }
}
