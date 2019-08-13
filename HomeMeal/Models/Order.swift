//
//  Order.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Order {
    var mealDetails: MealDetails
    var orderDetails: OrderDetails
    
    init(dictionary: [String:AnyObject]) {
        let mealDetailsDictionary = dictionary["mealDetails"] as! [String:AnyObject]
        self.mealDetails = MealDetails(dictionary: mealDetailsDictionary)
        let orderDetailsDictionary = dictionary["orderDetails"] as! [String:AnyObject]
        self.orderDetails = OrderDetails(dictionary: orderDetailsDictionary)
    }
    
    func getDictionary() -> [String:AnyObject]{
        let dictionary = [
            "mealDetails": self.mealDetails.getDictionary(),
            "orderDetails": self.orderDetails.getDictionary(),
            ] as [String : AnyObject]
        
        return dictionary
    }
}

