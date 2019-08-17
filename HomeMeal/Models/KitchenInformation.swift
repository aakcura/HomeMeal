//
//  Chef.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import CoreLocation

class KitchenInformation{
    var latitude: Double
    var longitude: Double
    var addressDescription: String
    
    init(dictionary: [String: Any]) {
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
        self.addressDescription = dictionary["addressDescription"] as! String
    }
    
    func getDictionary() -> [String:AnyObject]{
        return [
            "latitude": latitude,
            "longitude": longitude,
            "addressDescription": addressDescription
            ] as [String:AnyObject]
    }
    
    func getKitchenLocation() -> CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
}
