//
//  ArrayChanges.swift
//  SomaKit
//
//  Created by Anton on 06.08.16.
//  Copyright © 2016 iON1k. All rights reserved.
//

public enum ChangeType {
    case Replace
    case Insert
    case Delete
}

public struct ArrayChange {
    public let type: ChangeType
    public let index: Int
}

public class ArrayChangesCalculator {
    private typealias EquivalentIndexesPair = (oldIndex: Int, newIndex: Int)
    
    public static func calculateChanges(oldSource: [Equivalentable], newSource: [Equivalentable]) -> [ArrayChange] {
        var resultChanges = [ArrayChange]()
        
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
    
    private static func getChanges(oldSource: [Equivalentable], newSource: [Equivalentable],
                            leftIndexesPair: EquivalentIndexesPair?, rightIndexesPair: EquivalentIndexesPair?) -> [ArrayChange] {
        let newSourceLeftIndex = leftIndexesPair?.newIndex ?? -1
        let oldSourceLeftIndex = leftIndexesPair?.oldIndex ?? -1
        let newSourceRightIndex = rightIndexesPair?.newIndex ?? newSource.count
        let oldSourceRightIndex = rightIndexesPair?.oldIndex ?? oldSource.count
        
        var newIndex = newSourceLeftIndex + 1
        var oldIndex = oldSourceLeftIndex + 1
        
        var resultChanges = [ArrayChange]()
        
        while newIndex < newSourceRightIndex && oldIndex < oldSourceRightIndex {
            resultChanges.append(ArrayChange(type: .Replace, index: oldIndex))
            newIndex += 1
            oldIndex += 1
        }
        
        let lastOldIndex = oldIndex
        
        let deletingIndex = lastOldIndex
        while oldIndex < oldSourceRightIndex {
            resultChanges.append(ArrayChange(type: .Delete, index: deletingIndex))
            oldIndex += 1
        }
        
        var insertingIndex = lastOldIndex
        while newIndex < newSourceRightIndex {
            resultChanges.append(ArrayChange(type: .Insert, index: insertingIndex))
            newIndex += 1
            insertingIndex += 1
        }
        
        return resultChanges
    }
}
