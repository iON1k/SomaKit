//
//  NibFactory.swift
//  SomaKit
//
//  Created by Anton on 25.10.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

open class NibFactory<NibType: RawRepresentable>: FactoryType where NibType.RawValue == String {
    public typealias Instance = UINib
    public typealias InstanceType = NibType
    
    private let nibBundle: Bundle?
    
    public init(nibBundle: Bundle? = nil) {
        self.nibBundle = nibBundle
    }
    
    public func createInstance(type: InstanceType) -> Instance {
        return UINib(nibName: type.rawValue, bundle: nibBundle)
    }
}

public extension NibFactory {
    public func loadView<TView: UIView>(type: InstanceType, owner: Any? = nil, options: [AnyHashable : Any]? = nil) -> TView {
        guard let resultView = createInstance(type: type).instantiate(withOwner: owner, options: options).first as? TView else {
            Debug.fatalError("Nib factory view with type \(type) loading failed")
        }
        
        return resultView
    }
}
