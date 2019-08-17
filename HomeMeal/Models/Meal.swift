//
//  Meal.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Meal {
    var chefId: String
    var chefName: String
    var description: String
    var endTime: TimeInterval
    var detailedEndTime: DetailedTime?
    var ingredients: [Ingredient]?
    var mealId: String
    var mealName: String
    var mealStatus: MealStatus
    var preparationTime: TimeInterval
    var detailedPreparationTime: (Int,Int)
    var price: Double
    var currencySymbol: String
    var startTime: TimeInterval
    var detailedStartTime: DetailedTime?
    var chef: Chef?
    
    init(dictionary: [String:AnyObject]) {
        self.chefId = dictionary["chefId"] as! String
        self.chefName = dictionary["chefName"] as! String
        self.description = dictionary["description"] as! String
        self.endTime = dictionary["endTime"] as! TimeInterval
        self.detailedEndTime = self.endTime.getDetailedTime()
        if let ingredientsArray = dictionary["ingredients"] as? [AnyObject]{
            var ingredients = [Ingredient]()
            for item in ingredientsArray{
                if let ingredientDictionary = item as? [String:AnyObject]{
                    let ingredient = Ingredient(dictionary: ingredientDictionary)
                    ingredients.append(ingredient)
                }
            }
            if ingredients.count > 0 {
                self.ingredients = ingredients
            }
        }
        self.mealId = dictionary["mealId"] as! String
        self.mealName = dictionary["mealName"] as! String
        self.mealStatus = MealStatus(rawValue: dictionary["mealStatus"] as! Int) ?? MealStatus.canNotBeOrdered
        self.preparationTime = dictionary["preparationTime"] as! TimeInterval
        let (_, hour, minute, _) = self.preparationTime.getDayHourMinuteAndSecondAsInt()
        self.detailedPreparationTime = (hour,minute)
        
        self.price = dictionary["price"] as! Double
        self.currencySymbol = dictionary["currencySymbol"] as! String
        self.startTime = dictionary["startTime"] as! TimeInterval
        self.detailedStartTime = self.startTime.getDetailedTime()
    }
    
    func getDictionary() -> [String:AnyObject]{
        var dictionary = [
            "chefId": self.chefId,
            "chefName": self.chefName,
            "description": self.description,
            "endTime": self.endTime,
            "mealId": self.mealId,
            "mealName": self.mealName,
            "mealStatus": self.mealStatus.rawValue,
            "preparationTime": self.preparationTime,
            "price": self.price,
            "currencySymbol": self.currencySymbol,
            "startTime": self.startTime
            ] as [String : AnyObject]
        
        if let ingredients = self.ingredients{
            var arr = [[String:AnyObject]]()
            for item in ingredients{
                let ingredientAsJsonObject = item.getDictionary()
                arr.append(ingredientAsJsonObject)
            }
            if arr.count > 0 {
                dictionary["ingredients"] = arr as AnyObject
            }
        }
        
        return dictionary
    }
}
