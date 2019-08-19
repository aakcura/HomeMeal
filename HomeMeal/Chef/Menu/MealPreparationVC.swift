//
//  MealPreparationVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class MealPreparationVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblMealStackTitle: UILabel!
    @IBOutlet weak var lblDescriptionStackTitle: UILabel!
    @IBOutlet weak var lblIngredientsStackTitle: UILabel!
    @IBOutlet weak var lblIngredientName: UILabel!
    @IBOutlet weak var lblIngredientBrand: UILabel!
    
    @IBOutlet weak var lblPriceStackTitle: UILabel!
    @IBOutlet weak var lblStartTimeTitle: UILabel!
    @IBOutlet weak var lblEndTimeTitle: UILabel!
    @IBOutlet weak var lblPreparationTimeTitle: UILabel!
    @IBOutlet weak var lblMealStatusStackTitle: UILabel!
    @IBOutlet weak var lblMealStatus: UILabel!
    
    @IBOutlet weak var tfMealName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfIngredientName: UITextField!
    @IBOutlet weak var tfIngredientBrand: UITextField!
    @IBOutlet weak var pickerPriceCurrency: UIPickerView!
    @IBOutlet weak var pickerStartTime: UIDatePicker!
    @IBOutlet weak var pickerEndTime: UIDatePicker!
    @IBOutlet weak var pickerPreparationTime: UIPickerView!
    
    @IBOutlet weak var tvDescription: UITextView!
    
    @IBOutlet weak var tableIngredients: UITableView!
    @IBOutlet weak var switchMealStatus: UISwitch!
    
    @IBOutlet weak var btnAddIngredient: UIButton!
    
    @IBOutlet weak var btnPrepareMeal: UIButton!
    
    @IBOutlet weak var btnClose: UIButton!
    
    let btnPrepareMealTitle = "Prepare Meal".getLocalizedString()
    let btnCloseMealTitle = "Close Meal To Order".getLocalizedString()
    let btnUpdateMealTitle = "Update Meal".getLocalizedString()
    
    let currencySymbols = ["₺","$","£","€"]
    var hourArray: [Int] = []
    var minuteArray: [Int] = []
    var ingredients: [Ingredient] = []
    let ingredientsCellId = "ingredientsCell"
    
    var descriptionText: String? = nil
    var isMealNameValid:Bool = false
    var isDescriptionValid:Bool = false
    var isPriceValid: Bool = false
    
    let mealNameValidationRule = DefaultTextValidationRule(error: MyValidationErrors.nameInvalid)
    let priceValidationRule = PriceValidationRule(error: MyValidationErrors.priceInvalid)
    
    var mealStatus: MealStatus?
    var meal: Meal?{
        didSet{
            if let meal = self.meal{
                DispatchQueue.main.async { [weak self] in
                    
                    self?.tfMealName.text = meal.mealName
                    self?.isMealNameValid = true
                    
                    self?.descriptionText = meal.description
                    self?.tvDescription.textColor = UIColor.black
                    self?.tvDescription.text = self?.descriptionText
                    self?.isDescriptionValid = true
                    
                    if let mealIngredients = meal.ingredients {
                        self?.ingredients = mealIngredients
                        self?.tableIngredients.reloadData()
                    }
                    
                    self?.tfPrice.text = "\(meal.price)"
                    self?.isPriceValid = true
                    
                    let index = self?.currencySymbols.firstIndex(of: meal.currencySymbol) ?? 0
                    self?.pickerPriceCurrency.selectRow(index, inComponent: 0, animated: false)
                    
                    self?.pickerStartTime.date = Date(timeIntervalSince1970: meal.startTime)
                    self?.pickerEndTime.date = Date(timeIntervalSince1970: meal.endTime)
                    self?.pickerEndTime.isEnabled = true
                    
                    let (_,hour,minute,_) = meal.preparationTime.getDayHourMinuteAndSecondAsInt()
                    let hourIndex = self?.hourArray.firstIndex(of: hour) ?? 0
                    let minuteIndex = self?.minuteArray.firstIndex(of: minute) ?? 0
                    self?.pickerPreparationTime.selectRow(hourIndex, inComponent: 0, animated: false)
                    self?.pickerPreparationTime.selectRow(minuteIndex, inComponent: 2, animated: false)
                    
                    self?.writeMealStatus(meal.mealStatus)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        self.setNavBarTitle("Prepare Meal".getLocalizedString())
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        lblMealStackTitle.text = "Meal Name".getLocalizedString()
        tfMealName.placeholder = "MealNamePlaceholder".getLocalizedString()
        tfMealName.delegate = self
        tfMealName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lblDescriptionStackTitle.text = "Description".getLocalizedString()
        tvDescription.text = "MealDescriptionPlaceHolder".getLocalizedString()
        tvDescription.textColor = AppColors.textViewPlaceHolderColor
        tvDescription.delegate = self
        tvDescription.translatesAutoresizingMaskIntoConstraints = false
        tvDescription.setCornerRadius(radiusValue: 5.0)
        
        lblIngredientsStackTitle.text = "Ingredients".getLocalizedString()
        lblIngredientName.text = "Name".getLocalizedString()
        tfIngredientName.placeholder = "IngredientNamePlaceholder".getLocalizedString()
        
        lblIngredientBrand.text = "Brand".getLocalizedString()
        tfIngredientBrand.placeholder = "IngredientBrandPlaceholder".getLocalizedString()
        tableIngredients.register(IngredientsTableViewCell.self, forCellReuseIdentifier: ingredientsCellId)
        tableIngredients.delegate = self
        tableIngredients.dataSource = self
        tableIngredients.tableFooterView = UIView(frame: .zero)
        
        lblPriceStackTitle.text = "Price".getLocalizedString()
        tfPrice.delegate = self
        tfPrice.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        pickerPriceCurrency.dataSource = self
        pickerPriceCurrency.delegate = self
        pickerPriceCurrency.reloadAllComponents()
        
        lblStartTimeTitle.text = "Start Time".getLocalizedString()
        setStartTimePickerMinAndMaxDate()
        lblEndTimeTitle.text = "End Time".getLocalizedString()
        setEndTimePickerMinAndMaxDate()
        
        lblPreparationTimeTitle.text = "Preparation Time".getLocalizedString()
        for i in 0...23 {
            hourArray.append(i)
        }
        for i in 5...59 {
            minuteArray.append(i)
        }
        pickerPreparationTime.dataSource = self
        pickerPreparationTime.delegate = self
        pickerPreparationTime.reloadAllComponents()
        
        lblMealStatusStackTitle.text = "Meal".getLocalizedString()
        detectAndWriteMealStatus(switchMealStatus.isOn)
        
        btnPrepareMeal.translatesAutoresizingMaskIntoConstraints = false
        btnPrepareMeal.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnPrepareMeal.setTitle(btnPrepareMealTitle, for: .normal)
        
        btnClose.translatesAutoresizingMaskIntoConstraints = false
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
    }
    
    private func setStartTimePickerMinAndMaxDate(){
        pickerStartTime.minimumDate = Date(timeIntervalSinceNow: 10*60.0)
        pickerStartTime.maximumDate = Date(timeIntervalSinceNow: 7*24*60*60.0)
    }
    
    private func setEndTimePickerMinAndMaxDate(){
        pickerEndTime.minimumDate = pickerStartTime.date.addingTimeInterval(60*60.0)
        pickerEndTime.maximumDate = pickerEndTime.minimumDate!.addingTimeInterval(7*24*60*60.0)
    }
    
    private func insertNewIngredient(){
        if let ingredientName = tfIngredientName.text, !ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let ingredientBrand = tfIngredientBrand.text, !ingredientBrand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let ingredient = Ingredient(name: ingredientName, brand: ingredientBrand)
            ingredients.append(ingredient)
            tableIngredients.reloadData()
            tfIngredientName.text = ""
            tfIngredientBrand.text = ""
        }
    }
    
    private func writeMealStatus(_ mealStatus: MealStatus){
        DispatchQueue.main.async { [weak self] in
            switch mealStatus {
            case .canBeOrdered:
                self?.switchMealStatus.setOn(true, animated: false)
                self?.lblMealStatus.text = "can be ordered".getLocalizedString()
                self?.btnPrepareMeal.setTitle(self?.btnCloseMealTitle, for: .normal)
                break
            case .canNotBeOrdered:
                self?.switchMealStatus.setOn(false, animated: false)
                self?.lblMealStatus.text = "can't be ordered".getLocalizedString()
                self?.btnPrepareMeal.setTitle(self?.btnUpdateMealTitle, for: .normal)
                break
            }
        }
    }
    
    private func detectAndWriteMealStatus(_ status: Bool){
        self.mealStatus = status ? MealStatus.canBeOrdered : MealStatus.canNotBeOrdered
        DispatchQueue.main.async { [weak self] in
            switch (self?.mealStatus)!{
            case .canBeOrdered:
                self?.lblMealStatus.text = "can be ordered".getLocalizedString()
                break
            case .canNotBeOrdered:
                self?.lblMealStatus.text = "can't be ordered".getLocalizedString()
                break
            }
        }
    }
    
    func showActivityIndicatorView(isUserInteractionEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.view.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }
    
    func hideActivityIndicatorView(isUserInteractionEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }
    
    @IBAction func mealStatusChanged(_ sender: Any) {
        detectAndWriteMealStatus(switchMealStatus.isOn)
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        setEndTimePickerMinAndMaxDate()
    }
    
    @IBAction func endTimeChanged(_ sender: Any) {
    }
    
    @IBAction func addIngredientTapped(_ sender: Any) {
        insertNewIngredient()
    }
    
    @IBAction func prepareMealTapped(_ sender: Any) {
        if isMealNameValid && isDescriptionValid && isPriceValid{
            if NetworkManager.isConnectedNetwork(){
                guard let btnTitle = btnPrepareMeal.currentTitle else {return}
                if btnTitle == btnUpdateMealTitle {
                    updateMeal()
                }
                if btnTitle == btnPrepareMealTitle {
                    prepareMeal()
                }
                if btnTitle == btnCloseMealTitle {
                    closeMeal()
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                AlertService.showAlert(in: self, message: "Gerekli alanlar doldurulmalı", title: "", style: .alert)
            }
        }
    }
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// HANDLE MEAL PREPARATION & UPDATE
extension MealPreparationVC{
    func prepareMeal(){
        guard let currentChef = AppDelegate.shared.currentUserAsChef else {return}
        self.showActivityIndicatorView(isUserInteractionEnabled: false)
        let mealsDbRef = Database.database().reference().child("meals")
        guard let mealId = mealsDbRef.childByAutoId().key else{
            // TODO: Error handling
            self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            DispatchQueue.main.async {
                AlertService.showAlert(in: self, message: "Meal Creation Failed".getLocalizedString(), title: "", style: .alert)
            }
            return
        }
        
        let mealName = tfMealName.text ?? ""
        let price = Double(tfPrice.text!) ?? 0.0
        let currencySymbol = currencySymbols[pickerPriceCurrency.selectedRow(inComponent: 0)]
        let startTime = pickerStartTime.date.timeIntervalSince1970
        let endTime = pickerEndTime.date.timeIntervalSince1970
        let selectedHour = hourArray[pickerPreparationTime.selectedRow(inComponent: 0)]
        let selectedMinute = minuteArray[pickerPreparationTime.selectedRow(inComponent: 2)]
        let preparationTime = TimeInterval(((selectedHour * 60 * 60) + (selectedMinute * 60)))
        let mealStatus = switchMealStatus.isOn ? MealStatus.canBeOrdered : MealStatus.canNotBeOrdered
        
        var dictionary = [
            "chefId": currentChef.userId,
            "chefName": currentChef.name,
            "description": descriptionText ?? "",
            "endTime": endTime,
            "mealId": mealId,
            "mealName": mealName,
            "mealStatus": mealStatus.rawValue,
            "preparationTime": preparationTime,
            "price": price,
            "currencySymbol": currencySymbol,
            "startTime": startTime
            ] as [String : AnyObject]
        
        if self.ingredients.count > 0 {
            var arr = [[String:AnyObject]]()
            for item in self.ingredients{
                let ingredientAsJsonObject = item.getDictionary()
                arr.append(ingredientAsJsonObject)
            }
            if arr.count > 0 {
                dictionary["ingredients"] = arr as AnyObject
            }
        }
        mealsDbRef.child(mealId).setValue(dictionary) { (error, dbRef) in
            self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            if let error = error {
                AlertService.showAlert(in: self, message: error.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    let mealCreatedAlert = UIAlertController(title: "Meal Created".getLocalizedString(), message: "Meal Created Message".getLocalizedString(), preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "Ok".getLocalizedString(), style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    mealCreatedAlert.addAction(okButton)
                    self.present(mealCreatedAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func updateMeal(){
        guard let meal = self.meal else {return}
        self.showActivityIndicatorView(isUserInteractionEnabled: false)
        meal.mealName = tfMealName.text ?? ""
        meal.description = descriptionText ?? ""
        meal.price = Double(tfPrice.text!) ?? 0.0
        meal.currencySymbol = currencySymbols[pickerPriceCurrency.selectedRow(inComponent: 0)]
        meal.ingredients = ingredients.count > 0 ? ingredients : nil
        meal.startTime = pickerStartTime.date.timeIntervalSince1970
        meal.endTime = pickerEndTime.date.timeIntervalSince1970
        let selectedHour = hourArray[pickerPreparationTime.selectedRow(inComponent: 0)]
        let selectedMinute = minuteArray[pickerPreparationTime.selectedRow(inComponent: 3)]
        meal.preparationTime = TimeInterval(((selectedHour * 60 * 60) + (selectedMinute * 60)))
        meal.mealStatus = switchMealStatus.isOn ? MealStatus.canBeOrdered : MealStatus.canNotBeOrdered
            
        Database.database().reference().child("meals").child(meal.mealId).updateChildValues(meal.getDictionary(), withCompletionBlock: { (error, dbRef) in
            if let error = error{
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                AlertService.showAlert(in: self, message: error.localizedDescription)
            }else{
                self.meal = meal
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            }
        })
    }
    
    func closeMeal(){
        guard let meal = self.meal else {return}
        let closeMealAlert = UIAlertController(title: "Close Meal To Order".getLocalizedString(), message: "CloseMeal To Order Alert Message".getLocalizedString(), preferredStyle: .alert)
        let okButton =  UIAlertAction(title: "Ok".getLocalizedString(), style: .default) { (action) in
            self.showActivityIndicatorView(isUserInteractionEnabled: false)
            Database.database().reference().child("meals").child(meal.mealId).updateChildValues(["mealStatus":MealStatus.canNotBeOrdered.rawValue], withCompletionBlock: { (error, dbRef) in
                if let error = error{
                    self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    AlertService.showAlert(in: self, message: error.localizedDescription)
                }else{
                    meal.mealStatus = MealStatus.canNotBeOrdered
                    self.meal = meal
                    self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                }
            })
        }
        let closeButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        closeMealAlert.addAction(okButton)
        closeMealAlert.addAction(closeButton)
        self.present(closeMealAlert, animated: true, completion: nil)
    }
}

// CUSTOM PICKER VIEW
extension MealPreparationVC: UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == pickerPriceCurrency.tag{
            return 1
        }
        
        if pickerView.tag == pickerPreparationTime.tag{
            return 4
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == pickerPriceCurrency.tag{
            return currencySymbols.count
        }
        
        if pickerView.tag == pickerPreparationTime.tag{
            switch component{
            case 0:
                return hourArray.count
            case 1:
                return 1
            case 2:
                return minuteArray.count
            case 3:
                return 1
            default:
                return 0
            }
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == pickerPriceCurrency.tag{
            return currencySymbols[row]
        }
        
        if pickerView.tag == pickerPreparationTime.tag{
            switch component{
            case 0:
                return "\(hourArray[row]) "
            case 1:
                return "hour".getLocalizedString()
            case 2:
                return "\(minuteArray[row]) "
            case 3:
                return "min".getLocalizedString()
            default:
                return nil
            }
        }

        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Handle custom picker view selection
    }

}

// TEXT FIELD
extension MealPreparationVC: UITextFieldDelegate{
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == tfMealName.tag {
            guard let mealName = tfMealName.text else {return}
            isMealNameValid = mealName.validate(rule: mealNameValidationRule).isValid
            if isMealNameValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfMealName.backgroundColor = nil
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfMealName.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                }
            }
        }
        
        if textField.tag == tfPrice.tag {
            guard let price = tfPrice.text else {return}
            isPriceValid = price.validate(rule: priceValidationRule).isValid
            if isPriceValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfPrice.backgroundColor = nil
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfPrice.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
    }
}


// TEXT VIEW
extension MealPreparationVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.tvDescription.textColor == AppColors.textViewPlaceHolderColor {
            self.tvDescription.text = nil
            self.tvDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.tvDescription.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            self.tvDescription.text = "MealDescriptionPlaceHolder".getLocalizedString()
            self.tvDescription.textColor = AppColors.textViewPlaceHolderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else{ return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= AppConstants.mealDescriptionCharacterCountLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == tvDescription.tag {
            let description = tvDescription.text == "MealDescriptionPlaceHolder".getLocalizedString() ? nil : tvDescription.text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ")
            if let description = description, description != ""{
                tvDescription.backgroundColor = .white
                isDescriptionValid = true
                descriptionText = description
            }else{
                tvDescription.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                isDescriptionValid = false
                descriptionText = nil
            }
        }
    }
}


// TABLE VIEW
extension MealPreparationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ingredients.isEmpty {
            return 1
        }else{
            return ingredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ingredients.isEmpty {
            let emptyFavoriteMealCell = UITableViewCell()
            emptyFavoriteMealCell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
            emptyFavoriteMealCell.backgroundColor = .white
            emptyFavoriteMealCell.textLabel?.numberOfLines = 0
            emptyFavoriteMealCell.textLabel?.textAlignment = .center
            emptyFavoriteMealCell.textLabel?.text = "No Ingredients".getLocalizedString()
            return emptyFavoriteMealCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: self.ingredientsCellId, for: indexPath) as! IngredientsTableViewCell
            cell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
            let ingredient = ingredients[indexPath.row]
            cell.nameLabel.text = ingredient.name
            cell.brandLabel.text = ingredient.brand
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ingredients.isEmpty{
            return tableView.frame.height
        }else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        ingredients.remove(at: indexPath.row)
        tableView.reloadData()
    }
}
