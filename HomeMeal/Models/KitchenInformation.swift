//
//  Chef.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class KitchenInformation{
    var latitude: Double?
    var longitude: Double?
    
    init(dictionary: [String: Any]) {
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
    }
}
