//
//  Extension-String.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

extension String {
    func getLocalizedString(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "\(self)", comment: "")
    }
}
