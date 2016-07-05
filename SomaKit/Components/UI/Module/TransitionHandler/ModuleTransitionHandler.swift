//
//  ModuleTransitionHandler.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import UIKit

public protocol ModuleTransitionHandler {
    func openModule(module: UIViewController, transition: (UIViewController, UIViewController) -> Void)
    func closeModule(transition: UIViewController -> Void)
}


extension ModuleTransitionHandler {
    func pushModule(module: UIViewController, animated: Bool) {
        openModule(module) { (sourceModule, destinationModule) in
            sourceModule.navigationController?.pushViewController(destinationModule, animated: animated)
        }
    }
    
    func presentModule(module: UIViewController, animated: Bool) {
        openModule(module) { (sourceModule, destinationModule) in
            sourceModule.presentViewController(destinationModule, animated: animated, completion: nil)
        }
    }
    
    public func closeModule(animated: Bool) {
        closeModule { (module) in
            if let navigationController = module.parentViewController as? UINavigationController {
                if navigationController.childViewControllers.count > 1 {
                    navigationController.popViewControllerAnimated(animated)
                }
            } else if module.presentingViewController != nil {
                module.dismissViewControllerAnimated(animated, completion: nil)
            } else if module.view.superview != nil {
                module.removeFromParentViewController()
                module.view.removeFromSuperview()
            }
        }
    }
}