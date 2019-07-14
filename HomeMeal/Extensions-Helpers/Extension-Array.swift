//
//  Extension-Array.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
