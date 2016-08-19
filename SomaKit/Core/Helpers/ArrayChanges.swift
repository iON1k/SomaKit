//
//  ArrayChanges.swift
//  SomaKit
//
//  Created by Anton on 06.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum ArrayChangeType {
    case Replace
    case Insert
    case Delete
}

public struct ArrayChange<TElement> {
    public let type: ArrayChangeType
    public let index: Int
    public let element: TElement
    
    public init(type: ArrayChangeType, index: Int, element: TElement) {
        self.type = type
        self.index = index
        self.element = element
    }
}

public class ArrayChangesCalculator {
    private typealias EquivalentIndexesPair = (oldIndex: Int, newIndex: Int)
    
    public static func calculateChanges<TElement>(oldSource: [TElement], newSource: [TElement]) -> [ArrayChange<TElement>] {
        var resultChanges = [ArrayChange<TElement>]()
        
        var equivalentElementsIndexes = [EquivalentIndexesPair]()
        
        for (newIndex, newElement) in newSource.enumerate() {
            if let oldIndex = oldSource.indexOfEquivalent(newElement) {
                equivalentElementsIndexes.append((oldIndex, newIndex))
            }
        }
        
        let prevIndexesPair: EquivalentIndexesPair? = nil
        
        for nextIndexesPair in equivalentElementsIndexes {
            resultChanges.appendContentsOf(getChanges(oldSource, newSource: newSource, leftIndexesPair: prevIndexesPair, rightIndexesPair: nextIndexesPair))
        }
        
        resultChanges.appendContentsOf(getChanges(oldSource, newSource: newSource, leftIndexesPair: prevIndexesPair, rightIndexesPair: nil))
        
        return resultChanges
    }
    
    private static func getChanges<TElement>(oldSource: [TElement], newSource: [TElement],
                         leftIndexesPair: EquivalentIndexesPair?, rightIndexesPair: EquivalentIndexesPair?) -> [ArrayChange<TElement>] {
        let newSourceLeftIndex = leftIndexesPair?.newIndex ?? -1
        let oldSourceLeftIndex = leftIndexesPair?.oldIndex ?? -1
        let newSourceRightIndex = rightIndexesPair?.newIndex ?? newSource.count
        let oldSourceRightIndex = rightIndexesPair?.oldIndex ?? oldSource.count
        
        var newIndex = newSourceLeftIndex + 1
        var oldIndex = oldSourceLeftIndex + 1
        
        var resultChanges = [ArrayChange<TElement>]()
        
        while newIndex < newSourceRightIndex && oldIndex < oldSourceRightIndex {
            resultChanges.append(ArrayChange(type: .Replace, index: oldIndex, element: newSource[newIndex]))
            newIndex += 1
            oldIndex += 1
        }
        
        let lastOldIndex = oldIndex
        
        let deletingIndex = lastOldIndex
        while oldIndex < oldSourceRightIndex {
            resultChanges.append(ArrayChange(type: .Delete, index: deletingIndex, element: newSource[deletingIndex]))
            oldIndex += 1
        }
        
        var insertingIndex = lastOldIndex
        while newIndex < newSourceRightIndex {
            resultChanges.append(ArrayChange(type: .Insert, index: insertingIndex, element: newSource[newIndex]))
            newIndex += 1
            insertingIndex += 1
        }
        
        return resultChanges
    }
}