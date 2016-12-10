//
//  UIActivityIndicatorView+Extension.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

extension UIActivityIndicatorView: ActivityIndicator {
    public func setActive(active: Bool) {
        isHidden = !active

        if active {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
}
