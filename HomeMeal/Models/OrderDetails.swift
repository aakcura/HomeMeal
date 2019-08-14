//
//  OrderDetails.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class OrderDetails {
    var chefId: String
    var chefName: String
    var kitchenInformation: KitchenInformation
    var customerId: String
    var customerName: String
    var orderId: String
    var orderStatus: OrderStatus
    var orderTime: TimeInterval
    var commentId: String?
    
    var detailedOrderTime: DetailedTime?
    var chefRating: Double?
    var chefProfileImageUrl: String?
    var customerProfileImageUrl: String?
    
    
    init(dictionary: [String:AnyObject]) {
        let chefDetailsDictionary = dictionary["chefDetails"] as! [String:AnyObject]
        let customerDetailsDictionary = dictionary["customerDetails"] as! [String:AnyObject]
        
        // CHEF PROPERTIES
        self.chefId = chefDetailsDictionary["chefId"] as! String
        self.chefName = chefDetailsDictionary["chefName"] as! String
        let kitchenInformationDictionary = chefDetailsDictionary["kitchenInformation"] as! [String:AnyObject]
        self.kitchenInformation = KitchenInformation(dictionary: kitchenInformationDictionary)
        
        // CUSTOMER PROPERTIES
        self.customerId = customerDetailsDictionary["customerId"] as! String
        self.customerName = customerDetailsDictionary["customerName"] as! String
        
        // ORDER PROPERTIES
        self.orderId = dictionary["orderId"] as! String
        self.orderStatus = OrderStatus(rawValue: (dictionary["orderStatus"] as! Int)) ?? OrderStatus.rejected
        self.commentId = dictionary["commentId"] as? String
        self.orderTime = dictionary["orderTime"] as! TimeInterval
        self.detailedOrderTime = self.orderTime.getDetailedTime()
    }
    
    func getDictionary() -> [String:AnyObject]{
        let chefDetails = [
            "chefId": self.chefId,
            "chefName": self.chefName,
            "kitchenInformation": self.kitchenInformation.getDictionary()
            ] as [String:AnyObject]
        let customerDetails = [
            "customerId": self.customerId,
            "customerName": self.customerName
            ] as [String:AnyObject]
        
        let dictionary = [
            "chefDetails": chefDetails,
            "customerDetails": customerDetails,
            "orderId": self.orderId,
            "orderStatus": self.orderStatus.rawValue,
            "orderTime": self.orderTime,
            ] as [String : AnyObject]
        
        return dictionary
    }
}
