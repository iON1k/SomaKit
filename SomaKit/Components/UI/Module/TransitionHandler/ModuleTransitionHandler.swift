//
//  ModuleTransitionHandler.swift
//  SomaKit
//
//  Created by Anton on 05.07.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import UIKit

public protocol ModuleTransitionHandler {
    func openModule(_ module: UIViewController, transition: (UIViewController, UIViewController) -> Void)
    func closeModule(_ transition: (UIViewController) -> Void)
}


extension ModuleTransitionHandler {
    func pushModule(_ module: UIViewController, animated: Bool) {
        openModule(module) { (sourceModule, destinationModule) in
            sourceModule.navigationController?.pushViewController(destinationModule, animated: animated)
        }
    }
    
    func presentModule(_ module: UIViewController, animated: Bool) {
        openModule(module) { (sourceModule, destinationModule) in
            sourceModule.present(destinationModule, animated: animated, completion: nil)
        }
    }
    
    public func closeModule(_ animated: Bool) {
        closeModule { (module) in
            if let navigationController = module.parent as? UINavigationController {
                if navigationController.childViewControllers.count > 1 {
                    navigationController.popViewController(animated: animated)
                }
            } else if module.presentingViewController != nil {
                module.dismiss(animated: animated, completion: nil)
            } else if module.view.superview != nil {
                module.removeFromParentViewController()
                module.view.removeFromSuperview()
            }
        }
    }
}
