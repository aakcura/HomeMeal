//
//  CustomerOrderDetailsVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import Cosmos
//import CoreLocation
import MapKit

class CustomerOrderDetailsVC: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnAddComment: UIButton!
    
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
    
    @IBOutlet weak var mealDescriptionSectionView: UIView!
    @IBOutlet weak var lblMealDescriptionTitle: UILabel!
    @IBOutlet weak var tvMealDescription: UITextView!
    
    @IBOutlet weak var mealIngredientsSectionView: UIView!
    @IBOutlet weak var lblIngredientsTitle: UILabel!
    @IBOutlet weak var tableIngredients: UITableView!
    
    // ORDER DETAILS SECTION
    @IBOutlet weak var orderDetailsSectionView: UIView!
    @IBOutlet weak var lblOrderDetailsSectionTitle: UILabel!
    @IBOutlet weak var lblCurrentOrderStatus: UILabel!
    @IBOutlet weak var lblOrderTime: UILabel!
    @IBOutlet weak var btnComplaint: UIButton!
    
    // KITCHEN INFORMATION SECTION
    @IBOutlet weak var kitchenInformationSectionView: UIView!
    @IBOutlet weak var lblKitchenInformationSectionTitle: UILabel!
    @IBOutlet weak var tvKitchenAddressDescription: UITextView!
    @IBOutlet weak var btnKitchenLocation: UIButton!
    
    @IBOutlet weak var btnCancelOrder: UIButton!
    
    var defaultProfileImage = AppIcons.profileIcon
    var ingredients: [Ingredient]?
    let ingredientsTableCellId = "ingredientsTableCellId"
    var informationVC: InformationVC?
    
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
                let chefId = order.orderDetails.chefId
                let chefName = order.orderDetails.chefName
                self.getChef(by: chefId) { (chef) in
                    if let chef = chef {
                        self.chef = chef
                    }else{
                        self.configureProfileSectionWith(chefName, self.defaultProfileImage)
                    }
                }
                self.configurePage()
            }else{
                let errorMessage = "Order bulunamadı".getLocalizedString()
                self.changeInformationView(withMessage: errorMessage, shouldAnimating: false)
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
    
    var chef: Chef? {
        didSet{
            if let chef = self.chef{
                self.configureProfileSectionWith(chef)
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
        
        btnAddComment.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnAddComment.backgroundColor = AppColors.appYellowColor
        btnAddComment.setImage(AppIcons.pencilWhiteIcon, for: .normal)
        
        profileSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        profileSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        profileImageView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        
        //ratingView.isUserInteractionEnabled = false
        // Do not change rating when touched
        // Use if you need just to show the stars without getting user's input
        ratingView.settings.updateOnTouch = false
        // Show only fully filled stars
        ratingView.settings.fillMode = .precise
        // Other fill modes: .half, .precise
        
        btnGoToChefProfile.setTitle("go to chef's profile".getLocalizedString(), for: .normal)
        
        mealDetailsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealDescriptionSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealDescriptionSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealIngredientsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        mealIngredientsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        lblMealDescriptionTitle.text = "Description".getLocalizedString()
        lblIngredientsTitle.text = "Ingredients".getLocalizedString()
        tableIngredients.register(IngredientsTableViewCell.self, forCellReuseIdentifier: self.ingredientsTableCellId)
        
        orderDetailsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        orderDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblOrderDetailsSectionTitle.text = "Order Details".getLocalizedString()
        
        kitchenInformationSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        kitchenInformationSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblKitchenInformationSectionTitle.text = "Chef's Kitchen Information".getLocalizedString()
        
        
        btnCancelOrder.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnCancelOrder.setTitle("Cancel Order".getLocalizedString(), for: .normal)
        
        self.showInformationView(withMessage: "Siparişiniz getirilirken lütfen bekleyiniz".getLocalizedString(), showAsLoadingPage: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCommentTapped(_ sender: Any) {
        guard let order = self.order else {return}
        self.showCommentPopup(for: order)
    }
    
    @IBAction func goToChefProfileTapped(_ sender: Any) {
        // TODO: Go chef profile
        print("GO CHEF PROFİLE")
    }
    
    @IBAction func complaintTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to complain".getLocalizedString(), message: "".getLocalizedString(), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes".getLocalizedString(), style: .destructive) { (action) in
            let complaintAlert = UIAlertController(title: "Complaint".getLocalizedString(), message: "Can you state your complaint".getLocalizedString(), preferredStyle: .alert)
            complaintAlert.addTextField(configurationHandler: { (complainTextField:UITextField) in
                complainTextField.placeholder = "Enter your complaint message".getLocalizedString()
                complainTextField.textColor = UIColor.black
                complainTextField.delegate = self
            })
            let complainAction = UIAlertAction(title: "Complain".getLocalizedString(), style: .destructive) { (action) in
                if let complaintMessage = complaintAlert.textFields![0].text {
                    if !complaintMessage.isEmpty && !complaintMessage.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                        let values = [
                            "complainantUserAccountTypePath": "customers",
                            "complainantUserId": AppDelegate.shared.currentUserAsCustomer!.userId,
                            "complaintText": complaintMessage,
                            "orderId": self.order?.orderDetails.orderId ?? nil,
                            "suspiciousUserAccountTypePath": "chefs",
                            "suspiciousUserId": self.chef!.userId
                            ] as [String:AnyObject]
                        self.addNewComplaint(with: values, completion: { (error) in
                            if let error = error {
                                AlertService.showAlert(in: self, message: error.localizedDescription)
                            }else{
                                AlertService.showAlert(in: self, message: "We are dealing with your complaint".getLocalizedString(), title: "Your Complaint Was Received".getLocalizedString(), style: .alert)
                            }
                        })
                    }else{
                        AlertService.showAlert(in: self, message: "ComplaintMessageNotEntered".getLocalizedString(), title: "", style: .actionSheet)
                    }
                }else{
                    AlertService.showAlert(in: self, message: "ComplaintMessageNotEntered".getLocalizedString(), title: "", style: .actionSheet)
                }
            }
            let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
            complaintAlert.addAction(closeAction)
            complaintAlert.addAction(complainAction)
            self.present(complaintAlert, animated: true, completion: nil)
        }
        let noAction = UIAlertAction(title: "No".getLocalizedString(), style: .cancel, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
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
    
    
    @IBAction func cancelOrderTapped(_ sender: Any) {
        if NetworkManager.isConnectedNetwork() {
            if let order = self.order {
                let cancelOrderAlert = UIAlertController(title: "Sipariş İptali".getLocalizedString(), message: "Şiparişinizi iptal edilecek ve bu işlem geri alınamayacaktır devam etmek istiyormusunuz", preferredStyle: .alert)
                let cancelButton =  UIAlertAction(title: "Cancel Order".getLocalizedString(), style: .destructive) { (action) in
                    self.updateOrderStatus(orderId: order.orderDetails.orderId, orderStatus: .canceled) { (error) in
                        if let error = error{
                            AlertService.showAlert(in: self, message: error.localizedDescription)
                        }else{
                            order.orderDetails.orderStatus = .canceled
                            self.currentOrderStatus = order.orderDetails.orderStatus
                            AlertService.showAlert(in: self, message: "Siparişiniz başarıyla iptal edilmiştir".getLocalizedString())
                        }
                    }
                }
                let closeButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
                cancelOrderAlert.addAction(closeButton)
                cancelOrderAlert.addAction(cancelButton)
                self.present(cancelOrderAlert, animated: true, completion: nil)
            }else{
                AlertService.showAlert(in: self, message: "Sipariş bulunamadı".getLocalizedString())
            }
        }else{
            AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
        }
    }
}

// COMPLAINT MESSAGE SECTION
extension CustomerOrderDetailsVC: UITextFieldDelegate {
    
    func addNewComplaint(with values: [String:AnyObject],  completion: @escaping (Error?) -> Void){
        let dbRef = Database.database().reference().child("complaints")
        guard let newComplaintId = dbRef.childByAutoId().key else{
            DispatchQueue.main.async {
                AlertService.showAlert(in: self, message: "ComplainErrorMessage".getLocalizedString(), title: "", style: .alert)
            }
            return
        }
        dbRef.child(newComplaintId).setValue(values) { (error, dbRef) in
            completion(error)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= AppConstants.complaintMessageCharacterCountLimit
    }
}

// PAGE CONFIGURATION OPERATIONS
extension CustomerOrderDetailsVC {
    
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
            
            
            self.tvKitchenAddressDescription.text = order.orderDetails.kitchenInformation.addressDescription
            self.kitchenLocation = CLLocationCoordinate2D.init(latitude: order.orderDetails.kitchenInformation.latitude, longitude: order.orderDetails.kitchenInformation.longitude)
            
            self.hideInformationView()
        }
    }
    
    private func configureOrderStatus(){
        guard let currentOrderStatus = self.currentOrderStatus else {return}
        self.setOrderStatusText(for: currentOrderStatus)
        self.configureCommentButton()
        DispatchQueue.main.async {
            self.btnCancelOrder.isEnabled = true
            self.btnCancelOrder.isHidden = false
            switch currentOrderStatus {
            case .received:
                self.btnCancelOrder.isEnabled = true
                self.btnCancelOrder.isHidden = false
                break
            default:
                self.btnCancelOrder.isEnabled = false
                self.btnCancelOrder.isHidden = true
                break
            }
        }
    }

    private func configureCommentButton(){
        guard let currentOrderStatus = self.currentOrderStatus else {return}
        DispatchQueue.main.async {
            self.btnAddComment.isEnabled = true
            self.btnAddComment.isHidden = false
            switch currentOrderStatus {
            case .prepared:
                self.btnAddComment.isEnabled = true
                self.btnAddComment.isHidden = false
                break
            default:
                self.btnAddComment.isEnabled = false
                self.btnAddComment.isHidden = true
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
extension CustomerOrderDetailsVC {
    
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
extension CustomerOrderDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
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

// COMMENT VC DELEGATES
extension CustomerOrderDetailsVC: CommentVCPresentationDelegate, CommentVCDataTransferDelegate{

    func closeCommentPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showCommentPopup(for order:Order){
        let commentVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        commentVC.presentationDelegate = self
        commentVC.dataTransferDelegate = self
        commentVC.modalPresentationStyle = .overCurrentContext
        commentVC.modalTransitionStyle = .crossDissolve
        self.present(commentVC, animated: true, completion: nil)
        commentVC.order = order
    }
    
    func newCommentAddedWith(commentId: String) {
        guard let order = self.order else { return }
        order.orderDetails.commentId = commentId
    }
}
