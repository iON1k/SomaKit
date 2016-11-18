//
//  NibsFactory.swift
//  SomaKit
//
//  Created by Anton on 25.10.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import Foundation

public class NibsFactory<NibType: RawRepresentable> where NibType.RawValue == String {
    private let nibBundle: Bundle?
    
    public init(nibBundle: Bundle? = nil) {
        self.nibBundle = nibBundle
    }
    
    public func loadNib(type: NibType) -> UINib {
        return UINib(nibName: type.rawValue, bundle: nibBundle)
    }
    
    public func loadView<TView: UIView>(type: NibType, owner: Any? = nil, options: [AnyHashable : Any]? = nil) -> TView {
        guard let resultView = loadNib(type: type).instantiate(withOwner: owner, options: options).first as? TView else {
            Debug.fatalError("Nib factory view with name \(type) loading failed")
        }
        
        return resultView
    }
}
