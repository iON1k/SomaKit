//
//  Observable+Log.swift
//  SomaKit
//
//  Created by Anton on 26.06.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public extension Observable {
    public func logError(text: String, logLevel: LogLevel = .Error) -> Observable<E> {
        return self.doOnError({ (error) in
            Log.log(logLevel, message: text + "\n\(error)")
        })
    }
    
    public func logNext(text: String, logLevel: LogLevel = .Debug) -> Observable<E> {
        return self.doOnNext({ (element) in
            Log.log(logLevel, message: text + "\n\(element)")
        })
    }
    
    public func logCompleted(text: String, logLevel: LogLevel = .Debug) -> Observable<E> {
        return self.doOnCompleted({ 
            Log.log(logLevel, message: text)
        })
    }
}