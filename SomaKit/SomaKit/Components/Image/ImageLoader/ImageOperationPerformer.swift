//
//  ImageOperationPerformer.swift
//  SomaKit
//
//  Created by Anton on 25.11.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol ImageOperationPerformer {
    func performImageOperation(operation: ImageOperation) -> Observable<UIImage>
}
