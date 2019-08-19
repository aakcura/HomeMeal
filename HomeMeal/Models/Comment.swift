//
//  Comment.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Comment {
    
    var chefId: String
    var chefName: String
    var commentId: String
    var commentText: String?
    var commentTime: TimeInterval
    var detailedCommentTime: DetailedTime?
    var customerId: String
    var customerName: String
    var orderId: String
    var mealName: String
    var rating: Double
    
    init(dictionary: [String: Any]) {
        self.chefId = dictionary["chefId"] as! String
        self.chefName = dictionary["chefName"] as! String
        self.commentId = dictionary["commentId"] as! String
        self.commentText = dictionary["commentText"] as? String
        self.commentTime = dictionary["commentTime"] as! TimeInterval
        self.detailedCommentTime = self.commentTime.getDetailedTime()
        self.customerId = dictionary["customerId"] as! String
        self.customerName = dictionary["customerName"] as! String
        self.orderId = dictionary["orderId"] as! String
        self.mealName = dictionary["mealName"] as! String
        self.rating = dictionary["rating"] as! Double
    }
    
    func getDictionary() -> [String:AnyObject] {
        var dictionary = [
            "chefId": self.chefId,
            "chefName": self.chefName,
            "commentId": self.commentId,
            "commentTime": self.commentTime,
            "customerId": self.customerId,
            "customerName": self.customerName,
            "orderId": self.orderId,
            "mealName": self.mealName,
            "rating": self.rating
            ] as [String:AnyObject]
        
        if let commentText = self.commentText {
            dictionary["commentText"] = commentText as AnyObject
        }
        
        return dictionary
    }
    
}
