//
//  CustomerProfileVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class CustomerProfileVC: BaseVC, ChooseEmailActionSheetPresenter {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    // CHEF PROFILE DETAILS SECTION
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblCustomerName: UILabel!
    
    @IBOutlet weak var socialAccountsSectionView: UIView!
    @IBOutlet weak var lblSocialAccountsSectionTitle: UILabel!
    @IBOutlet weak var socialAccountsButtonStack: UIStackView!
    
    @IBOutlet weak var biographySectionView: UIView!
    @IBOutlet weak var lblBiographySectionTitle: UILabel!
    @IBOutlet weak var tvBiography: UITextView!
    
    @IBOutlet weak var allergiesSectionView: UIView!
    @IBOutlet weak var lblAllergiesSectionTitle: UILabel!
    @IBOutlet weak var tableAllergies: UITableView!
    
    @IBOutlet weak var favoriteMealsSectionView: UIView!
    @IBOutlet weak var lblFavoriteMealsSectionTitle: UILabel!
    @IBOutlet weak var tableFavoriteMeals: UITableView!
    
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    var defaultProfileImage = AppIcons.profileIcon
    var informationVC: InformationVC?
    var allergies: [String] = []
    var favoriteMeals: [String] = []
    
    var customerId: String?
    var customer: Customer?
    var presentationType: ProfileScreensPresentationType?
    
    var chooseEmailActionSheet: UIAlertController? {
        return setupChooseEmailActionSheet(withTitle: "Contact Us".getLocalizedString())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
        self.determinePresantationTypeAndConfigureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let presentationType = self.presentationType, presentationType == .currentUser {
            guard let currentCustomer = AppDelegate.shared.currentUserAsCustomer else {return}
            self.customer = currentCustomer
            configurePageWith(user: self.customer!, presentationType: presentationType)
        }
    }
    
    private func determinePresantationTypeAndConfigureUI(){
        guard let presentationType = self.presentationType else {return}
        if presentationType == .currentUser {
            guard let currentCustomer = AppDelegate.shared.currentUserAsCustomer else {return}
            self.customer = currentCustomer
            configurePageWith(user: self.customer!, presentationType: presentationType)
        }
        
        if presentationType == .anyUser {
            if let customer = self.customer {
                configurePageWith(user: customer, presentationType: presentationType)
            }else{
                if let customerId = customerId {
                    self.showInformationView(withMessage: "Customer getiriliyor bekleyiniz".getLocalizedString(), showAsLoadingPage: true)
                    self.getUserByUserId(customerId) { (customer) in
                        if let customer = customer {
                            self.customer = customer
                            self.configurePageWith(user: customer, presentationType: presentationType)
                            self.hideInformationView()
                        }else{
                            self.changeInformationView(withMessage: "Customer bulunamadı".getLocalizedString(), shouldAnimating: false)
                        }
                    }
                }
            }
        }
    }
    
    private func setupUIProperties(){
        self.view.backgroundColor = .white
        self.informationVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "InformationVC") as! InformationVC
        
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
        
        // PROFILE SECTION
        profileSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        profileSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        profileImageView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        
        // SOCIAL MEDIA ACCOUNTS SECTION
        socialAccountsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        socialAccountsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblSocialAccountsSectionTitle.text = "Social Media Accounts".getLocalizedString()
        
        // BIOGRAPHY SECTION
        biographySectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        biographySectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblBiographySectionTitle.text = "Biography".getLocalizedString()
        
        // ALLERGIES SECTION
        allergiesSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        allergiesSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblAllergiesSectionTitle.text = "Allergies".getLocalizedString()
        tableAllergies.delegate = self
        tableAllergies.dataSource = self
        tableAllergies.tableFooterView = UIView(frame: .zero)
        
        // FAVORITE MEAL SECTION
        favoriteMealsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        favoriteMealsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblFavoriteMealsSectionTitle.text = "Favorite Meals".getLocalizedString()
        tableFavoriteMeals.delegate = self
        tableFavoriteMeals.dataSource = self
        tableFavoriteMeals.tableFooterView = UIView(frame: .zero)
    }
    
    
    private func configurePageWith(user:Customer, presentationType: ProfileScreensPresentationType){
        if presentationType == .currentUser {
            customizeNavBarForCurrentUser()
            btnClose.isHidden = true
        }
        
        if presentationType == .anyUser {
            customizeNavBarForAnyUser()
            btnClose.isHidden = false
        }
        
        configurePageWithUserInformations(user)
    }
    
    
    private func configurePageWithUserInformations(_ user:Customer){
        DispatchQueue.main.async {
            if let profileImageUrl = user.profileImageUrl {
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl, defaultImage: AppIcons.profileIcon)
            }else{
                self.profileImageView.image = AppIcons.profileIcon
            }
            
            self.lblCustomerName.text = user.name
            
            // TODO: CONFIGURE SOCIAL ACCOUNTS
            for view in self.socialAccountsButtonStack.arrangedSubviews{
                self.socialAccountsButtonStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            if let socialAccounts = user.socialAccounts {
                for item in socialAccounts{
                    let btn = SocialMediaAccountButton(type: .system)
                    btn.translatesAutoresizingMaskIntoConstraints = false
                    btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
                    btn.setSocialMediaAccount(item)
                    self.socialAccountsButtonStack.addArrangedSubview(btn)
                }
            }else{
                let lblNoSocialMediaAccounts = UILabel()
                lblNoSocialMediaAccounts.textAlignment = .center
                lblNoSocialMediaAccounts.textColor = .black
                lblNoSocialMediaAccounts.font = UIFont.boldSystemFont(ofSize: 14)
                lblNoSocialMediaAccounts.text = "No Social Media Accounts".getLocalizedString()
                self.socialAccountsButtonStack.addArrangedSubview(lblNoSocialMediaAccounts)
            }
            
            self.tvBiography.text = user.biography
            self.allergies = user.allergies ?? []
            self.favoriteMeals = user.favoriteMeals ?? []
            self.tableAllergies.reloadData()
            self.tableFavoriteMeals.reloadData()
        }
    }
    
    
    private func customizeNavBarForAnyUser(){
        self.setNavBarTitle("Profile".getLocalizedString())
        let backBarButtton = UIBarButtonItem(image: AppIcons.arrowLeftIcon, style: .plain, target: self, action: #selector(self.closeVC))
        self.navigationItem.leftBarButtonItem = backBarButtton
    }
    
    private func customizeNavBarForCurrentUser(){
        self.setNavBarTitle("Profile".getLocalizedString())
        let settingsBarButtonItem = UIBarButtonItem(image: AppIcons.settingsIcon, style: .plain, target: self, action: #selector(settingsButtonClicked))
        self.navigationItem.rightBarButtonItem = settingsBarButtonItem
    }
    
    @objc func closeVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func settingsButtonClicked() {
        let alert = UIAlertController(title: "Settings".getLocalizedString(), message: nil, preferredStyle: .actionSheet)
        
        let goToProfileSettingsAction = UIAlertAction(title: "Go to Profile Settings".getLocalizedString(), style: .default) { (action) in
            self.goToProfileSettings()
        }
        
        let contactUsViaMailAction = UIAlertAction(title: "Contact Us".getLocalizedString(), style: .default) { (action) in
            self.contactUsViaMail()
        }
        
        let shareAppAction = UIAlertAction(title: "Share App".getLocalizedString(), style: .default) { (action) in
            self.shareApp()
        }
        
        let signOutAction = UIAlertAction(title: "Sign Out".getLocalizedString(), style: .destructive) { (action) in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out".getLocalizedString(), preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes".getLocalizedString(), style: .destructive) { (action) in
                self.signOut()
            }
            let noAction = UIAlertAction(title: "No".getLocalizedString(), style: .default, handler: nil)
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        
        alert.addAction(goToProfileSettingsAction)
        alert.addAction(contactUsViaMailAction)
        alert.addAction(shareAppAction)
        alert.addAction(signOutAction)
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func signOut(){
        // store the user session (example only, not for the production)
        if NetworkManager.isConnectedNetwork(){
            do {
                if let uid = AppConstants.currentUserId, let sessionId = UserDefaults.standard.string(forKey: UserDefaultsKeys.userSessionId), let accountType = AppDelegate.shared.currentUserAccountType{
                    let dbRef = Database.database().reference()
                    if accountType == .chef {
                        dbRef.child("chefs").child(uid).child("fcmToken").removeValue()
                    }else if accountType == .customer {
                        dbRef.child("customers").child(uid).child("fcmToken").removeValue()
                    }
                    let sessionsRef = dbRef.child("sessions").child(uid).child(sessionId)
                    let values = [ "endTime" : Date().timeIntervalSince1970, "sessionStatus": SessionStatus.passive.rawValue] as [String:AnyObject]
                    sessionsRef.updateChildValues(values) { (error, ref) in
                        if let error = error {
                            // TODO: Error handling
                            print(error.localizedDescription)
                            return
                        }
                    }
                }
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
                AppDelegate.shared.rootViewController.switchToLogout()
            } catch let signOutError as NSError {
                DispatchQueue.main.async { [weak self] in
                    AlertService.showAlert(in: self, message: "Error signing out: \(signOutError)", style: .alert)
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
            }
        }
    }
}

// SHOW OPTIONS
extension CustomerProfileVC {
    func setPresentationProperties(_ presentationType:ProfileScreensPresentationType, customer:Customer?, customerId: String?){
        self.presentationType = presentationType
        if presentationType == .anyUser {
            if let customer = customer {
                self.customer = customer
            }else{
                if let customerId = customerId {
                    self.customerId = customerId
                }
            }
        }
    }
}

// INFORMATION VIEW METHODS
extension CustomerProfileVC {
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
}

// FIRABASE OPERATIONS
extension CustomerProfileVC {
    private func getUserByUserId(_ userId:String, completion: @escaping (Customer?) -> Void){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("customers/\(userId)").observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = Customer(dictionary: dictionary)
                    completion(user)
                }else{
                    completion(nil)
                }
            }
        }else{
            self.changeInformationView(withMessage: "NoInternetConnectionErrorMessage".getLocalizedString(), shouldAnimating: false)
        }
    }
}

// SETTINGS SECTION
extension CustomerProfileVC {
    
    @objc func shareApp(){
        self.getAppShareMessage { (message) in
            if let message = message {
                DispatchQueue.main.async {
                    let activityController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                    self.present(activityController, animated: true)
                }
            }else{
                return
            }
        }
    }
    
    @objc func contactUsViaMail() {
        guard let emailActionSheet = chooseEmailActionSheet else{
            return
        }
        
        if let action = openAction(withURL: MailInformations.appleMailURL, andTitleActionTitle: "Through Mail".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: MailInformations.gmailURL, andTitleActionTitle: "Through Gmail".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: MailInformations.outlookURL, andTitleActionTitle: "Through Outlook".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "WebSiteURL".getLocalizedString(), andTitleActionTitle: "Through Website".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "Terms, and Data Policy URL".getLocalizedString(), andTitleActionTitle: "Show Terms and Data Policy".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        present(emailActionSheet, animated: true, completion: nil)
    }
    
    private func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
        guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (action) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return action
    }
    
    private func goToProfileSettings(){
        guard let user = self.customer else { return }
        let profileSettingsVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "CustomerProfileEditVC") as! CustomerProfileEditVC
        profileSettingsVC.customer = user
        let profileSettingsNavigationController = UINavigationController(rootViewController: profileSettingsVC)
        self.present(profileSettingsNavigationController, animated: true, completion: nil)
    }
}

// TABLE VIEW
extension CustomerProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableAllergies {
            if allergies.isEmpty {
                return 1
            }else{
                return allergies.count
            }
        }
        if tableView == tableFavoriteMeals {
            if favoriteMeals.isEmpty {
                return 1
            }else{
                return favoriteMeals.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.setBorder(borderWidth: 1, borderColor: .black)
        cell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        cell.backgroundColor = AppColors.appGoldColor
        
        if tableView == tableAllergies {
            if allergies.isEmpty {
                let emptyAllergyCell = UITableViewCell()
                //emptyAllergyCell.setBorder(borderWidth: 1, borderColor: .black)
                emptyAllergyCell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
                emptyAllergyCell.backgroundColor = .white
                emptyAllergyCell.textLabel?.numberOfLines = 0
                emptyAllergyCell.textLabel?.textAlignment = .center
                emptyAllergyCell.textLabel?.text = "No Allergies Found".getLocalizedString()
                return emptyAllergyCell
            }else{
                let allergy = allergies[indexPath.row]
                cell.textLabel?.text = allergy
            }
        }
        
        if tableView == tableFavoriteMeals {
            if favoriteMeals.isEmpty {
                let emptyFavoriteMealCell = UITableViewCell()
                emptyFavoriteMealCell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
                emptyFavoriteMealCell.backgroundColor = .white
                emptyFavoriteMealCell.textLabel?.numberOfLines = 0
                emptyFavoriteMealCell.textLabel?.textAlignment = .center
                emptyFavoriteMealCell.textLabel?.text = "No Favorite Meal Found".getLocalizedString()
                return emptyFavoriteMealCell
            }else{
                let favoriteMeal = favoriteMeals[indexPath.row]
                cell.textLabel?.text = favoriteMeal
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableAllergies {
            if allergies.isEmpty{
                return tableView.frame.height
            }else{
                return 30
            }
        }
        if tableView == tableFavoriteMeals {
            if favoriteMeals.isEmpty{
                return tableView.frame.height
            }else{
                return 30
            }
        }
        
        return 30
    }
}
