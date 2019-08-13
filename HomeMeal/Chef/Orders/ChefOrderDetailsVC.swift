//
//  OrderDetailVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class ChefOrderDetailsVC: BaseVC {

    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    // CUSTOMER PROFILE DETAILS SECTION
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblCustomerName: UILabel!
    
    // MEAL DETAILS SECTION
    @IBOutlet weak var lblMealName: UILabel!
    @IBOutlet weak var verticalSeparatorLine: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPreparationTime: UILabel!
    @IBOutlet weak var lblMealDescriptionTitle: UILabel!
    @IBOutlet weak var tvMealDescription: UITextView!
    @IBOutlet weak var lblIngredientsTitle: UILabel!
    @IBOutlet weak var tableIngredients: UITableView!
    
    // ORDER DETAILS SECTION
    @IBOutlet weak var orderDetailsSectionView: UIView!
    @IBOutlet weak var lblOrderDetailsSectionTitle: UILabel!
    @IBOutlet weak var lblCurrentOrderStatus: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    @IBOutlet weak var lblSelectNewOrderStatusTitle: UILabel!
    @IBOutlet weak var orderStatusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnUpdateOrderStatus: UIButton!
    
    var defaultProfileImage = AppIcons.profileIcon
    var ingredients: [Ingredient]?
    let ingredientsTableCellId = "ingredientsTableCellId"
    var selectedOrderStatus: OrderStatus?
    
    var orderId: String?{
        didSet{
            if let orderId = self.orderId {
                self.getOrder(by: orderId) { (order) in
                    if let order = order{
                        self.order = order
                    }else{
                        self.order = nil
                    }
                }
            }else{
                self.order = nil
            }
        }
    }
    
    var order: Order? {
        didSet{
            if let order = self.order {
                let customerId = order.orderDetails.customerId
                let customerName = order.orderDetails.customerName
                self.getCustomer(by: customerId) { (customer) in
                    if let customer = customer {
                        self.customer = customer
                    }else{
                        self.configureProfileSectionWith(customerName, self.defaultProfileImage)
                    }
                }
                self.configurePage()
            }else{
                let errorMessage = "Order bulunamadı".getLocalizedString()
                self.changeErrorView(withMessage: errorMessage, shouldAnimating: false)
            }
        }
    }
    
    var currentOrderStatus: OrderStatus? {
        didSet{
            if self.currentOrderStatus != nil {
                self.configureOrderStatus()
            }
        }
    }

    var customer: Customer? {
        didSet{
            if let customer = self.customer{
                self.configureProfileSectionWith(customer)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
        
        profileSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        profileSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        profileImageView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        
        lblMealName.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        lblMealName.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
       lblMealDescriptionTitle.text = "Description".getLocalizedString()
        lblIngredientsTitle.text = "Ingredients".getLocalizedString()
        tableIngredients.register(IngredientsTableViewCell.self, forCellReuseIdentifier: self.ingredientsTableCellId)
        
        orderDetailsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        orderDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblOrderDetailsSectionTitle.text = "Order Details".getLocalizedString()
        
        
        lblSelectNewOrderStatusTitle.text = "Change Order Status".getLocalizedString()
        
        orderStatusSegmentedControl.setTitle(OrderStatusText.Reject.text, forSegmentAt: 0)
        orderStatusSegmentedControl.setTitle(OrderStatusText.Preparing.text, forSegmentAt: 1)
        orderStatusSegmentedControl.setTitle(OrderStatusText.Prepared.text, forSegmentAt: 2)

        btnUpdateOrderStatus.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnUpdateOrderStatus.setTitle("Update Order Status".getLocalizedString(), for: .normal)
        
        self.showErrorView(withMessage: "Sipariş getirilirken lütfen bekleyiniz".getLocalizedString(), asLoadingPage: true)
    }
    
    var tapped = 0
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateOrderStatusTapped(_ sender: Any) {
        if NetworkManager.isConnectedNetwork() {
            if let order = self.order {
                if let newOrderStatus = self.selectedOrderStatus{
                    if newOrderStatus == order.orderDetails.orderStatus {
                        AlertService.showAlert(in: self, message: "Şipariş durumunda güncellemeye gerek yok")
                    }else{
                        self.updateOrderStatus(orderId: order.orderDetails.orderId, orderStatus: newOrderStatus) { (error) in
                            if let error = error{
                                AlertService.showAlert(in: self, message: error.localizedDescription)
                            }else{
                                order.orderDetails.orderStatus = newOrderStatus
                                self.currentOrderStatus = order.orderDetails.orderStatus
                                AlertService.showAlert(in: self, message: "Sipariş durumunuz başarıyla güncellendi")
                            }
                        }
                    }
                }else{
                    AlertService.showAlert(in: self, message: "Şipariş durumunda güncellemeye gerek yok")
                }
            }else{
                AlertService.showAlert(in: self, message: "Sipariş bulunamadı")
            }
        }else{
            AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
        }
    }
    
    @IBAction func orderStatusSegmentedControlValueChanged(_ sender: Any) {
        switch self.orderStatusSegmentedControl.selectedSegmentIndex {
        case 0:
            self.selectedOrderStatus = OrderStatus.rejected
            break
        case 1:
            self.selectedOrderStatus = OrderStatus.preparing
            break
        case 2:
            self.selectedOrderStatus = OrderStatus.prepared
            break
        default:
            self.selectedOrderStatus = nil
            break
        }
    }
    
}

// PAGE CONFIGURATION OPERATIONS
extension ChefOrderDetailsVC {
    
    private func showErrorView(withMessage:String, asLoadingPage:Bool){
        DispatchQueue.main.async {
            if asLoadingPage {
                self.view.sendSubviewToBack(self.scrollView)
                self.view.sendSubviewToBack(self.btnClose)
                self.view.bringSubviewToFront(self.errorView)
                self.errorActivityIndicator.startAnimating()
                self.errorLabel.text = withMessage
                self.errorView.isHidden = false
            }else{
                self.view.sendSubviewToBack(self.scrollView)
                self.view.bringSubviewToFront(self.errorView)
                self.view.bringSubviewToFront(self.btnClose)
                self.errorActivityIndicator.stopAnimating()
                self.errorLabel.text = withMessage
                self.errorView.isHidden = false
            }
        }
    }
    
    private func changeErrorView(withMessage:String, shouldAnimating:Bool){
        DispatchQueue.main.async {
            self.errorLabel.text = withMessage
            if shouldAnimating {
                self.errorActivityIndicator.startAnimating()
                self.view.sendSubviewToBack(self.btnClose)
            }else{
                self.errorActivityIndicator.stopAnimating()
                self.view.bringSubviewToFront(self.btnClose)
            }
        }
    }
    
    private func hideErrorView(asLoadingPage:Bool){
        DispatchQueue.main.async {
            if asLoadingPage {
                self.view.sendSubviewToBack(self.errorView)
                self.errorView.isHidden = true
                self.errorLabel.text = nil
                self.errorActivityIndicator.stopAnimating()
                self.view.bringSubviewToFront(self.scrollView)
                self.view.bringSubviewToFront(self.btnClose)
            }else{
                self.view.sendSubviewToBack(self.errorView)
                self.errorView.isHidden = true
                self.errorLabel.text = nil
                self.errorActivityIndicator.stopAnimating()
                self.view.bringSubviewToFront(self.scrollView)
                self.view.bringSubviewToFront(self.btnClose)
            }
        }
    }
    
    private func configureProfileSectionWith(_ customer: Customer){
        DispatchQueue.main.async {
            if let profileImageUrl = customer.profileImageUrl{
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl, defaultImage: self.defaultProfileImage)
            }else{
                self.profileImageView.image = self.defaultProfileImage
            }
            
            self.lblCustomerName.text = customer.name
        }
    }
    
    private func configureProfileSectionWith(_ customerName: String, _ profileImage: UIImage){
        DispatchQueue.main.async {
            self.profileImageView.image = profileImage
            self.lblCustomerName.text = customerName
        }
    }
    
    private func configurePage(){
        guard let order = self.order else {return}
        DispatchQueue.main.async {
            
            self.lblMealName.text = order.mealDetails.mealName
            
            let priceText = "Price".getLocalizedString() + " \(order.mealDetails.price) " + order.mealDetails.currencySymbol
            self.lblPrice.text = priceText
            
            let clockIconWithText = NSMutableAttributedString(string: AppIcons.faClockRegular)
            clockIconWithText.addCustomAttributes(fontType: .regularFontAwesome, fontSize: 17, color: .black, range: nil, underlineStyle: nil)
            let hourText = "hour".getLocalizedString()
            let minuteText = "min".getLocalizedString()
            let (hour,minute) = order.mealDetails.detailedPreparationTime
            var preparationTimeString = ""
            if hour == 0 {
                preparationTimeString = " \(minute) " + minuteText
            }else{
                preparationTimeString = " \(hour) " + hourText + " \(minute) " + minuteText
            }
            let preparationTimeText = NSMutableAttributedString(string: preparationTimeString)
            clockIconWithText.append(preparationTimeText)
            self.lblPreparationTime.attributedText = clockIconWithText
            
            self.tvMealDescription.text = order.mealDetails.description
            
            self.ingredients = order.mealDetails.ingredients
            self.reloadTableViewAsync()
            
            self.currentOrderStatus = order.orderDetails.orderStatus
            
            let orderTimeText = "Order Time".getLocalizedString() + ": "
            let attributedOrderTimeText = NSMutableAttributedString(string: orderTimeText)
            attributedOrderTimeText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
            if let orderDateAndTimeString = order.orderDetails.detailedOrderTime?.dateAndTimeFullString{
                let attributedOrderDateAndTimeString = NSMutableAttributedString(string: orderDateAndTimeString)
                attributedOrderTimeText.append(attributedOrderDateAndTimeString)
            }
            
            self.lblOrderTime.attributedText = attributedOrderTimeText
            
            self.hideErrorView(asLoadingPage: true)
        }
    }
    
    private func configureOrderStatus(){
        guard let currentOrderStatus = self.currentOrderStatus else {return}
        self.setOrderStatusText(for: currentOrderStatus)
        DispatchQueue.main.async {
            self.orderStatusSegmentedControl.setEnabled(true, forSegmentAt: 0)
            self.orderStatusSegmentedControl.setEnabled(true, forSegmentAt: 1)
            self.orderStatusSegmentedControl.setEnabled(true, forSegmentAt: 2)
            switch currentOrderStatus {
            case .received:
                break
            case .canceled:
                self.orderStatusSegmentedControl.isEnabled = false
                self.btnUpdateOrderStatus.isEnabled = false
                break
            case .rejected:
                self.orderStatusSegmentedControl.setEnabled(false, forSegmentAt: 0)
                break
            case .preparing:
                self.orderStatusSegmentedControl.setEnabled(false, forSegmentAt: 1)
                break
            case .prepared:
                self.orderStatusSegmentedControl.setEnabled(false, forSegmentAt: 2)
                break
            }
        }
    }
    
    private func setOrderStatusText(for orderStatus:OrderStatus){
        let currentOrderStatusText = "Current Order Status".getLocalizedString() + ": "
        let attributedCurrentOrderStatusText = NSMutableAttributedString(string: currentOrderStatusText)
        attributedCurrentOrderStatusText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        var orderStatusString = ""
        switch orderStatus {
        case .received:
            orderStatusString = OrderStatusText.received.text
            break
        case .canceled:
            orderStatusString = OrderStatusText.canceled.text
            break
        case .rejected:
            orderStatusString = OrderStatusText.rejected.text
            break
        case .preparing:
            orderStatusString = OrderStatusText.preparing.text
            break
        case .prepared:
            orderStatusString = OrderStatusText.prepared.text
            break
        }
        let orderStatusText = NSMutableAttributedString(string: orderStatusString)
        attributedCurrentOrderStatusText.append(orderStatusText)
        lblCurrentOrderStatus.attributedText = attributedCurrentOrderStatusText
    }
}

// FIREBASE OPERATIONS
extension ChefOrderDetailsVC {
    
    private func updateOrderStatus(orderId:String, orderStatus:OrderStatus, completion: @escaping (Error?) -> Void){
        let values = ["orderStatus":orderStatus.rawValue] as [String:AnyObject]
        let path = "orders/\(orderId)/orderDetails/"
        Database.database().reference().child(path).updateChildValues(values) { (error, dbRef) in
            if let error = error {
                completion(error)
            }else{
                completion(nil)
            }
        }
    }
    
    private func getCustomer(by customerId:String, completion: @escaping (Customer?) -> Void){
        Database.database().reference().child("customers/\(customerId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let customer = Customer(dictionary: dictionary)
                completion(customer)
            }else{
                completion(nil)
            }
        })
    }
    
    private func getOrder(by orderId:String, completion: @escaping (Order?) -> Void){
        Database.database().reference().child("orders/\(orderId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let order = Order(dictionary: dictionary)
                completion(order)
            }else{
                completion(nil)
            }
        })
    }
}

// TABLE VIEW
extension ChefOrderDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
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
