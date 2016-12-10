//
//  ContentState.swift
//  SomaKit
//
//  Created by Anton on 10.12.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum ContentState {
    case unknown
    case loading
    case normal(isEmpty: Bool)
    case error(error: Error)
    case custom(context: Any)
}
