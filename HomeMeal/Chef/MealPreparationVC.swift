//
//  MealPreparationVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var pickerPreparationTime: UIDatePicker!
    
    @IBOutlet weak var tvDescription: UITextView!
    
    @IBOutlet weak var tableIngredients: UITableView!
    @IBOutlet weak var switchMealStatus: UISwitch!
    
    @IBOutlet weak var btnAddIngredient: UIButton!
    
    @IBOutlet weak var btnPrepareMeal: UIButton!
    
    let btnPrepareMealTitle = "Prepare Meal".getLocalizedString()
    let btnUpdateMealTitle = "Update Meal".getLocalizedString()
    
    let currencySymbols = ["₺","$","£","€"]
    var ingredients: [Ingredient] = []
    let ingredientsCellId = "ingredientsCell"
    
    var descriptionText: String? = nil
    var isMealNameValid:Bool = false
    var isDescriptionValid:Bool = false
    var isPriceValid: Bool = false
    var isStartTimeValid:Bool = false
    var isEndTimeValid:Bool = false
    var isPreparationTimeValid:Bool = false
    
    let mealNameValidationRule = DefaultTextValidationRule(error: MyValidationErrors.nameInvalid)
    let priceValidationRule = PriceValidationRule(error: MyValidationErrors.priceInvalid)
    
    var mealStatus: MealStatus?
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        self.setNavBarTitle("Prepare Meal".getLocalizedString())
        setupUIProperties()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let meal = meal {
            tfMealName.text = meal.mealName
            isMealNameValid = true
            
            descriptionText = meal.description
            tvDescription.textColor = UIColor.black
            tvDescription.text = descriptionText
            isDescriptionValid = true
            
            if let mealIngredients = meal.ingredients {
                ingredients = mealIngredients
                tableIngredients.reloadData()
            }
            
            tfPrice.text = "\(meal.price)"
            isPriceValid = true
            
           let index = currencySymbols.firstIndex(of: meal.currencySymbol) ?? 0
            pickerPriceCurrency.selectRow(index, inComponent: 0, animated: false)
            
            pickerStartTime.date = Date(timeIntervalSince1970: meal.startTime)
            pickerEndTime.date = Date(timeIntervalSince1970: meal.endTime)
            pickerPreparationTime.date = Date(timeIntervalSinceNow: meal.preparationTime)
            
            writeMealStatus(meal.mealStatus)
        }
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
        
        pickerPreparationTime.date = Date(timeIntervalSince1970: 0)
        
        lblStartTimeTitle.text = "Start Time".getLocalizedString()
        lblEndTimeTitle.text = "End Time".getLocalizedString()
        lblPreparationTimeTitle.text = "Preparation Time".getLocalizedString()
        
        lblMealStatusStackTitle.text = "Meal Status".getLocalizedString()
        detectAndWriteMealStatus(switchMealStatus.isOn)
        
        btnPrepareMeal.setTitle(btnPrepareMealTitle, for: .normal)
    }
    
    private func setDatePickerMinAndMaxDate(){
        pickerStartTime.minimumDate = Date(timeIntervalSinceNow: 10*60.0)
        pickerStartTime.maximumDate = Date(timeIntervalSinceNow: 7*24*60*60.0)
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
                self?.lblMealStatus.text = "Can be ordered".getLocalizedString()
                break
            case .canNotBeOrdered:
                self?.switchMealStatus.setOn(false, animated: false)
                self?.lblMealStatus.text = "Can't be ordered".getLocalizedString()
                break
            }
            self?.btnPrepareMeal.setTitle(self?.btnUpdateMealTitle, for: .normal)
        }
    }
    
    private func detectAndWriteMealStatus(_ status: Bool){
        self.mealStatus = status ? MealStatus.canBeOrdered : MealStatus.canNotBeOrdered
        DispatchQueue.main.async { [weak self] in
            switch (self?.mealStatus)!{
            case .canBeOrdered:
                self?.lblMealStatus.text = "Can be ordered".getLocalizedString()
                break
            case .canNotBeOrdered:
                self?.lblMealStatus.text = "Can't be ordered".getLocalizedString()
                break
            }
        }
    }
    
    @IBAction func mealStatusChanged(_ sender: Any) {
        detectAndWriteMealStatus(switchMealStatus.isOn)
    }
    
   
    
    @IBAction func startTimeChanged(_ sender: Any) {
        print(pickerStartTime.date)
    }
    
    @IBAction func endTimeChanged(_ sender: Any) {
        print(pickerEndTime.date)
    }
    
    @IBAction func preparationTimeChanged(_ sender: Any) {
        let date = pickerPreparationTime.date
        let x = pickerPreparationTime.date.timeIntervalSinceNow
        let y = pickerPreparationTime.date.timeIntervalSinceReferenceDate
        let time = pickerPreparationTime.date.timeIntervalSince1970
        let detailed = TimeInterval.detailedTimeFromTimeInterval(timeInterval: time)
        
        print(pickerPreparationTime.date.timeIntervalSinceNow)
    }
    
    
    @IBAction func addIngredientTapped(_ sender: Any) {
        insertNewIngredient()
    }
    
    @IBAction func prepareMealTapped(_ sender: Any) {
        guard let btnTitle = btnPrepareMeal.currentTitle else {return}
        if btnTitle == btnUpdateMealTitle {
            updateMeal()
        }
        
        if btnTitle == btnPrepareMealTitle {
            prepareMeal()
        }
    }
}

// HANDLE MEAL PREPARATION & UPDATE
extension MealPreparationVC{
    func prepareMeal(){
        print("prepare meal clicked")
        print(pickerPreparationTime.date.timeIntervalSince1970)
    }
    
    func updateMeal(){
        print("update meal clicked")
    }
}

// CUSTOM PICKER
extension MealPreparationVC: UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencySymbols.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencySymbols[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print("Seçilen para birimi:",currencySymbols[row])
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
        return changedText.count <= AppConstants.biographyCharacterCountLimit
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
            cell.backgroundColor = UIColor.lightGray
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
            return 40
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
