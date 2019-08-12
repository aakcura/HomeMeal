//
//  Ingredient.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Ingredient{
    var name: String
    var brand: String
    
    init(name:String,brand:String) {
        self.name = name
        self.brand = brand
    }
    
    init(dictionary: [String:AnyObject]) {
        self.name = dictionary["name"] as! String
        self.brand = dictionary["brand"] as! String
    }
    
    func getDictionary() -> [String:AnyObject]{
        return ["name":self.name, "brand":self.brand] as [String:AnyObject]
    }
}
