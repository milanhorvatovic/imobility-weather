//
//  SortDescriptor.swift
//  iMobility Weather
//
//  Created by worker on 18/12/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

struct SortDescriptor<Type> {
    
    typealias Comparator = (Type, Type) -> Bool
    
    let ascending: Bool?
    let comparator: Comparator
    
    init<Property>(property: @escaping (Type) -> Property,
                   ascending: Bool,
                   comparator: @escaping (Property) -> (Property) -> ComparisonResult) {
        self.ascending = ascending
        self.comparator = { (lhs: Type, rhs: Type) -> Bool in
            return comparator(property(lhs))(property(rhs)) == (ascending ? .orderedAscending : .orderedDescending)
        }
    }
    
    init<Property>(property: @escaping (Type) -> Property,
                   comparator: @escaping (Property, Property) -> Bool) {
        self.ascending = nil
        self.comparator = { (lhs: Type, rhs: Type) -> Bool in
            return comparator(property(lhs), property(rhs))
        }
    }
    
    init<Property>(property: @escaping (Type) -> Property?,
                   ascending: Bool) where Property: Comparable {
        self.ascending = ascending
        self.comparator = { (lhs: Type, rhs: Type) -> Bool in
            let lhsProperty: Property? = property(lhs)
            let rhsProperty: Property? = property(rhs)
            switch ascending {
            case true:
                if let lhsProperty: Property = lhsProperty, let rhsProperty: Property = rhsProperty {
                    return lhsProperty < rhsProperty
                }
                else if let _: Property = lhsProperty {
                    return true
                }
                else {
                    return false
                }
            case false:
                if let lhsProperty: Property = lhsProperty, let rhsProperty: Property = rhsProperty {
                    return lhsProperty > rhsProperty
                }
                else if let _: Property = rhsProperty {
                    return true
                }
                else {
                    return false
                }
            }
        }
    }
    
    init(comparator: @escaping (Type, Type) -> Bool) {
        self.ascending = nil
        self.comparator = comparator
    }
    
    func sort(lhs: Type, rhs: Type) -> Bool {
        return self.comparator(lhs, rhs)
    }
    
}

extension SortDescriptor {
    
    static func combine<Type>(_ sortDescriptors: [SortDescriptor<Type>]) -> SortDescriptor<Type> {
        return SortDescriptor<Type>(comparator: { (lhs, rhs) in
            for sortDescriptor in sortDescriptors {
                if sortDescriptor.sort(lhs: lhs, rhs: rhs) {
                    return true
                }
                if sortDescriptor.sort(lhs: rhs, rhs: lhs) {
                    return false
                }
            }
            return false
        })
    }
    
}

extension Sequence {
    
    func sorted(by sortDescriptor: SortDescriptor<Element>) -> [Element] {
        return self.sorted(by: sortDescriptor.comparator)
    }
    
}
