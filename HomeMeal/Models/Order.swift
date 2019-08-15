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
    
    /// Use this initializer for create new order
    init(newOrderId:String, meal:Meal, chef:Chef, customer:Customer) {
        self.mealDetails = MealDetails(meal: meal)
        self.orderDetails = OrderDetails(newOrderId: newOrderId, chef: chef, customer: customer)
    }
    
    func getDictionary() -> [String:AnyObject]{
        let dictionary = [
            "mealDetails": self.mealDetails.getDictionary(),
            "orderDetails": self.orderDetails.getDictionary(),
            ] as [String : AnyObject]
        
        return dictionary
    }
}

