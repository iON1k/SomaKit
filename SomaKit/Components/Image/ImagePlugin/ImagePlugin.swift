//
//  ImagePlugin.swift
//  SomaKit
//
//  Created by Anton on 27.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public protocol ImagePlugin {
    func transform(image: UIImage) throws -> UIImage
    var cachingKey: String { get }
}
