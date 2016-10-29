//
//  TableViewBehavior.swift
//  SomaKit
//
//  Created by Anton on 04.09.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

import RxSwift

public protocol TableViewBehavior {
    var sectionModels: Observable<[TableViewSectionModelType]> { get }
    
    var isDataLoading: Observable<Bool> { get }
    
    func beginRefreshData() -> Observable<Void>
}

public protocol TableViewBehaviorProvider {
    associatedtype TableBehavior: TableViewBehavior
    
    var tableBehavior: TableBehavior { get }
}
