//
//  ImageBluring.swift
//  SomaKit
//
//  Created by Anton on 28.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public class ImageBluring: ImageFiltering {
    public init(radius: CGFloat) {
        super.init(name: "CIGaussianBlur", params: ["inputRadius": radius])
    }
}
