//
//  Observable+Log.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension Observable {
    public func logError(_ text: String, logLevel: LogLevel = .error) -> Observable<E> {
        return self.do(onError: { (error) in
            Log.log(logLevel, message: text + "\n\(error)")
        })
    }
    
    public func logNext(_ text: String, logLevel: LogLevel = .debug) -> Observable<E> {
        return self.do(onNext: { (element) in
            Log.log(logLevel, message: text + "\n\(element)")
        })
    }
    
    public func logCompleted(_ text: String, logLevel: LogLevel = .debug) -> Observable<E> {
        return self.do(onCompleted: { 
            Log.log(logLevel, message: text)
        })
    }
}
