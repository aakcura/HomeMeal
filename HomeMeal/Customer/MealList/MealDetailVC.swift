//
//  MealDetailVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import Cosmos

class MealDetailVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    // CHEF PROFILE DETAILS SECTION
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblChefName: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var btnGoToChefProfile: UIButton!
    
    // MEAL DETAILS SECTION
    @IBOutlet weak var mealDetailsSectionView: UIView!
    @IBOutlet weak var lblMealName: UILabel!
    @IBOutlet weak var verticalSeparatorLine: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPreparationTime: UILabel!
    
    @IBOutlet weak var mealTimeDetailsSectionView: UIView!
    @IBOutlet weak var lblMealTimeDetailsSectionTitle: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    @IBOutlet weak var mealDescriptionSectionView: UIView!
    @IBOutlet weak var lblMealDescriptionTitle: UILabel!
    @IBOutlet weak var tvMealDescription: UITextView!
    
    @IBOutlet weak var mealIngredientsSectionView: UIView!
    @IBOutlet weak var lblIngredientsTitle: UILabel!
    @IBOutlet weak var tableIngredients: UITableView!
    
    // KITCHEN INFORMATION SECTION
    @IBOutlet weak var kitchenInformationSectionView: UIView!
    @IBOutlet weak var lblKitchenInformationSectionTitle: UILabel!
    @IBOutlet weak var tvKitchenAddressDescription: UITextView!
    @IBOutlet weak var btnKitchenLocation: UIButton!
    
    @IBOutlet weak var btnGiveOrder: UIButton!
    
    var defaultProfileImage = AppIcons.profileIcon
    var ingredients: [Ingredient]?
    let ingredientsTableCellId = "ingredientsTableCellId"
    var informationVC: InformationVC?
    
    var mealId: String?{
        didSet{
            if let mealId = self.mealId {
                self.getMeal(by: mealId) { (meal) in
                    if let meal = meal{
                        self.meal = meal
                    }else{
                        self.meal = nil
                    }
                }
                
            }else{
                self.meal = nil
            }
        }
    }
    
    var meal: Meal? {
        didSet{
            if let meal = self.meal {
                let chefId = meal.chefId
                let chefName = meal.chefName
                if let chef = meal.chef {
                    self.chef = chef
                }else{
                    if self.chef == nil {
                        self.getChef(by: chefId) { (chef) in
                            if let chef = chef {
                                self.chef = chef
                            }else{
                                self.configureProfileSectionWith(chefName, self.defaultProfileImage)
                            }
                        }
                    }
                }
                self.configurePage()
            }else{
                let errorMessage = "Meal Not Found".getLocalizedString()
                self.changeInformationView(withMessage: errorMessage, shouldAnimating: false)
            }
        }
    }
    
    var chef: Chef? {
        didSet{
            if let chef = self.chef{
                self.configureProfileSectionWith(chef)
                self.configureKitchenInformationSectionWith(chef)
            }
        }
    }
    
    var kitchenLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        self.informationVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "InformationVC") as! InformationVC
        
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
        
        profileSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        profileSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealDetailsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealTimeDetailsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealTimeDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealDescriptionSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealDescriptionSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealIngredientsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealIngredientsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        kitchenInformationSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        kitchenInformationSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        profileImageView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        
        ratingView.settings.updateOnTouch = false
        ratingView.settings.fillMode = .precise
        
        btnGoToChefProfile.setTitle("Go To Chef's Profile Button Title".getLocalizedString(), for: .normal)
        
        //lblMealName.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        //lblMealName.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        lblMealDescriptionTitle.text = "Description".getLocalizedString()
        lblIngredientsTitle.text = "Ingredients".getLocalizedString()
        tableIngredients.register(IngredientsTableViewCell.self, forCellReuseIdentifier: self.ingredientsTableCellId)
        

        lblMealTimeDetailsSectionTitle.text = "Can Be Ordered Between".getLocalizedString()
        
        
        lblKitchenInformationSectionTitle.text = "Chef's Kitchen Information".getLocalizedString()
        
        
        btnGiveOrder.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnGiveOrder.setTitle("Place an Order".getLocalizedString(), for: .normal)
        
        self.showInformationView(withMessage: "Please wait while fetching meal information".getLocalizedString(), showAsLoadingPage: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goToChefProfileTapped(_ sender: Any) {
        // TODO: Go chef profile
        guard let chef = self.meal?.chef else {return}
        let chefProfileVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "ChefProfileVC") as! ChefProfileVC
        chefProfileVC.setPresentationProperties(.anyUser, chef: chef, chefId: nil)
        self.present(chefProfileVC, animated: true, completion: nil)
    }
    
    @IBAction func kitchenLocationTapped(_ sender: Any) {
        guard let kitchenLocation = self.kitchenLocation else { return }
        
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegion(center: kitchenLocation, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: kitchenLocation, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Chef's Kitchen Location".getLocalizedString()
        mapItem.openInMaps(launchOptions: options)
    }

    @IBAction func giveOrderTapped(_ sender: Any) {
        if NetworkManager.isConnectedNetwork() {
            if let meal = self.meal, let chef = self.chef, let customer = AppDelegate.shared.currentUserAsCustomer {
                guard let newOrderId = Database.database().reference().child("orders").childByAutoId().key else{
                    DispatchQueue.main.async {
                        AlertService.showAlert(in: self, message: "Order Creation Failed, Try Again".getLocalizedString(), title: "", style: .alert)
                    }
                    return
                }
                
                let giveOrderAlert = UIAlertController(title: "Place an Order".getLocalizedString(), message: "Approval for Meal Selection".getLocalizedString(), preferredStyle: .alert)
                let giveOrderButton =  UIAlertAction(title: "Place an Order".getLocalizedString(), style: .default) { (action) in
                    let newOrder = Order(newOrderId: newOrderId, meal: meal, chef: chef, customer: customer)
                    self.giveOrder(newOrderId: newOrderId, values: newOrder.getDictionary(), completion: { (error) in
                        if let error = error {
                            AlertService.showAlert(in: self, message: error.localizedDescription)
                        }else{
                            let alert = UIAlertController(title: "Order Received".getLocalizedString(), message: "Enjoy Your Meal".getLocalizedString(), preferredStyle: .alert)
                            let closeButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: { (action) in
                                self.closeTapped(true)
                            })
                            alert.addAction(closeButton)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
                let cancelButton = UIAlertAction(title: "Cancel".getLocalizedString(), style: .cancel, handler: nil)
                giveOrderAlert.addAction(cancelButton)
                giveOrderAlert.addAction(giveOrderButton)
                self.present(giveOrderAlert, animated: true, completion: nil)
            }else{
                AlertService.showAlert(in: self, message: "Order Action Is Not Available".getLocalizedString())
            }
        }else{
            AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
        }
    }
    
}

// PAGE CONFIGURATION OPERATIONS
extension MealDetailVC {
    
    private func showInformationView(withMessage:String, showAsLoadingPage:Bool){
        guard let informationVC = self.informationVC else {return}
        DispatchQueue.main.async {
            self.addChild(informationVC)
            informationVC.didMove(toParent: self)
            informationVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(informationVC.view)
            informationVC.view.fillSuperView()
            if showAsLoadingPage {
                informationVC.configureInformationVC(message: withMessage, shouldAnimate: true, showCloseButton: false)
            }else{
                informationVC.configureInformationVC(message: withMessage, shouldAnimate: false, showCloseButton: true)
            }
        }
    }
    
    private func changeInformationView(withMessage:String, shouldAnimating:Bool){
        guard let informationVC = self.informationVC else {return}
        DispatchQueue.main.async {
            if shouldAnimating {
                informationVC.configureInformationVC(message: withMessage, shouldAnimate: true, showCloseButton: false)
            }else{
                informationVC.configureInformationVC(message: withMessage, shouldAnimate: false, showCloseButton: true)
            }
        }
    }
    
    private func hideInformationView(){
        guard let informationVC = self.informationVC else {return}
        DispatchQueue.main.async {
            informationVC.view.removeFromSuperview()
        }
    }
    
    // CHEF'S SECTIONS CONFIGURATIONS
    private func configureProfileSectionWith(_ chef: Chef){
        DispatchQueue.main.async {
            if let profileImageUrl = chef.profileImageUrl{
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl, defaultImage: self.defaultProfileImage)
            }else{
                self.profileImageView.image = self.defaultProfileImage
            }
            
            self.lblChefName.text = chef.name
            self.ratingView.rating = chef.rating
        }
    }
    
    private func configureProfileSectionWith(_ chefName: String, _ profileImage: UIImage){
        DispatchQueue.main.async {
            self.profileImageView.image = profileImage
            self.lblChefName.text = chefName
            self.ratingView.rating = 0.0
        }
    }
    
    private func configureKitchenInformationSectionWith(_ chef: Chef){
        DispatchQueue.main.async {
            self.tvKitchenAddressDescription.text = chef.kitchenInformation.addressDescription
            self.kitchenLocation = CLLocationCoordinate2D(latitude: chef.kitchenInformation.latitude, longitude: chef.kitchenInformation.longitude)
        }
    }
    
    
    // MEAL'S SECTIONS CONFIGURATIONS
    private func configureMealDetailsSection(){
         guard let meal = self.meal else {return}
        self.lblMealName.text = meal.mealName
        
        let priceText = "Price".getLocalizedString() + " \(meal.price) " + meal.currencySymbol
        self.lblPrice.text = priceText
        
        let clockIconWithText = NSMutableAttributedString(string: AppIcons.faClockRegular)
        clockIconWithText.addCustomAttributes(fontType: .regularFontAwesome, fontSize: 17, color: .black, range: nil, underlineStyle: nil)
        let hourText = "hour".getLocalizedString()
        let minuteText = "min".getLocalizedString()
        let (hour,minute) = meal.detailedPreparationTime
        var preparationTimeString = ""
        if hour == 0 {
            preparationTimeString = " \(minute) " + minuteText
        }else{
            preparationTimeString = " \(hour) " + hourText + " \(minute) " + minuteText
        }
        let preparationTimeText = NSMutableAttributedString(string: preparationTimeString)
        clockIconWithText.append(preparationTimeText)
        self.lblPreparationTime.attributedText = clockIconWithText
    }
    
    private func configureMealTimeDetailsSection(){
        guard let meal = self.meal else {return}
        let startTimeText = "Start Time".getLocalizedString() + ": "
        let attributedStartTimeText = NSMutableAttributedString(string: startTimeText)
        attributedStartTimeText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        if let startDateAndTimeString = meal.detailedStartTime?.dateAndTimeFullString{
            let attributedStartDateAndTimeString = NSMutableAttributedString(string: startDateAndTimeString)
            attributedStartTimeText.append(attributedStartDateAndTimeString)
        }
        self.lblStartTime.attributedText = attributedStartTimeText
        
        let endTimeText = "End Time".getLocalizedString() + ": "
        let attributedEndTimeText = NSMutableAttributedString(string: endTimeText)
        attributedEndTimeText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        if let endDateAndTimeString = meal.detailedEndTime?.dateAndTimeFullString{
            let attributedEndDateAndTimeString = NSMutableAttributedString(string: endDateAndTimeString)
            attributedEndTimeText.append(attributedEndDateAndTimeString)
        }
        self.lblEndTime.attributedText = attributedEndTimeText
    }
    
    private func configureMealDescriptionSection(){
        guard let meal = self.meal else {return}
         self.tvMealDescription.text = meal.description
    }
    
    private func configureMealIngredientsSection(){
        guard let meal = self.meal else {return}
        self.ingredients = meal.ingredients
        self.reloadTableViewAsync()
    }
    
    private func configurePage(){
        DispatchQueue.main.async {
            self.configureMealDetailsSection()
            self.configureMealTimeDetailsSection()
            self.configureMealDescriptionSection()
            self.configureMealIngredientsSection()
            self.hideInformationView()
        }
    }
}

// FIREBASE OPERATIONS
extension MealDetailVC {
    
    private func giveOrder(newOrderId: String, values: [String:AnyObject], completion: @escaping (Error?) -> Void){
        // TODO: Write order function
        let dbPath = "orders/\(newOrderId)"
        Database.database().reference().child(dbPath).setValue(values) { (error, dbRef) in
            completion(error)
        }
    }
    
    private func getChef(by chefId:String, completion: @escaping (Chef?) -> Void){
        Database.database().reference().child("chefs/\(chefId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let chef = Chef(dictionary: dictionary)
                completion(chef)
            }else{
                completion(nil)
            }
        })
    }
    
    private func getMeal(by mealId:String, completion: @escaping (Meal?) -> Void){
        Database.database().reference().child("meals/\(mealId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let meal = Meal(dictionary: dictionary)
                completion(meal)
            }else{
                completion(nil)
            }
        })
    }
}

// TABLE VIEW
extension MealDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    private func reloadTableViewAsync(){
        if tableIngredients.dataSource != nil && tableIngredients.delegate != nil {
            DispatchQueue.main.async {
                self.tableIngredients.reloadData()
            }
        }else{
            tableIngredients.dataSource = self
            tableIngredients.delegate = self
            DispatchQueue.main.async {
                self.tableIngredients.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ingredients = self.ingredients, !ingredients.isEmpty{
            return ingredients.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ingredients = self.ingredients, !ingredients.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: self.ingredientsTableCellId, for: indexPath) as! IngredientsTableViewCell
            cell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
            let ingredient = ingredients[indexPath.row]
            cell.nameLabel.text = ingredient.name
            cell.brandLabel.text = ingredient.brand
            return cell
        }else{
            let emptyIngredientCell = UITableViewCell()
            emptyIngredientCell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
            emptyIngredientCell.backgroundColor = .white
            emptyIngredientCell.textLabel?.numberOfLines = 0
            emptyIngredientCell.textLabel?.textAlignment = .center
            emptyIngredientCell.textLabel?.text = "No Ingredients".getLocalizedString()
            return emptyIngredientCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let ingredients = self.ingredients, !ingredients.isEmpty{
            return 30
        }else{
            return tableView.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
