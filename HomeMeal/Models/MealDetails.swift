//
//  MealDetails.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class MealDetails {
    var currencySymbol: String
    var description: String
    var ingredients: [Ingredient]?
    var mealName: String
    var preparationTime: TimeInterval
    var detailedPreparationTime: (Int,Int)
    var price: Double
    
    init(dictionary: [String:AnyObject]) {
        self.currencySymbol = dictionary["currencySymbol"] as! String
        self.description = dictionary["description"] as! String
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
        self.mealName = dictionary["mealName"] as! String
        self.preparationTime = dictionary["preparationTime"] as! TimeInterval
        let (_, hour, minute, _) = self.preparationTime.getDayHourMinuteAndSecondAsInt()
        self.detailedPreparationTime = (hour,minute)
        self.price = dictionary["price"] as! Double
    }
    
    init(meal:Meal) {
        self.currencySymbol = meal.currencySymbol
        self.description = meal.description
        self.ingredients = meal.ingredients
        self.mealName = meal.mealName
        self.preparationTime = meal.preparationTime
        let (_, hour, minute, _) = self.preparationTime.getDayHourMinuteAndSecondAsInt()
        self.detailedPreparationTime = (hour,minute)
        self.price = meal.price
    }
    
    func getDictionary() -> [String:AnyObject]{
        var dictionary = [
            "currencySymbol": self.currencySymbol,
            "description": self.description,
            "mealName": self.mealName,
            "preparationTime": self.preparationTime,
            "price": self.price
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
