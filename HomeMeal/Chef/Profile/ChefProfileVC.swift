//
//  ChefProfileVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import Cosmos
import MapKit

class ChefProfileVC: UIViewController, ChooseEmailActionSheetPresenter {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    // CHEF PROFILE DETAILS SECTION
    @IBOutlet weak var profileSectionView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblChefName: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var btnSeeChefReviews: UIButton!
    
    @IBOutlet weak var socialAccountsSectionView: UIView!
    @IBOutlet weak var lblSocialAccountsSectionTitle: UILabel!
    @IBOutlet weak var socialAccountsButtonStack: UIStackView!
    
    @IBOutlet weak var biographySectionView: UIView!
    @IBOutlet weak var lblBiographySectionTitle: UILabel!
    @IBOutlet weak var tvBiography: UITextView!
    
    @IBOutlet weak var chefBestMealsSectionView: UIView!
    @IBOutlet weak var lblChefBestMealsSectionTitle: UILabel!
    @IBOutlet weak var tableBestMeals: UITableView!
    
    // KITCHEN INFORMATION SECTION
    @IBOutlet weak var kitchenInformationSectionView: UIView!
    @IBOutlet weak var lblKitchenInformationSectionTitle: UILabel!
    @IBOutlet weak var tvKitchenAddressDescription: UITextView!
    @IBOutlet weak var btnKitchenLocation: UIButton!

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func seeChefReviewsTapped(_ sender: Any) {
        // see chef reviews
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
    
    var kitchenLocation: CLLocationCoordinate2D?
    var defaultProfileImage = AppIcons.profileIcon
    var bestMeals: [String] = []
    let ingredientsTableCellId = "ingredientsTableCellId"
    var informationVC: InformationVC?

    
    var user: Chef?
    
    var chooseEmailActionSheet: UIAlertController? {
        return setupChooseEmailActionSheet(withTitle: "Contact Us".getLocalizedString())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        self.view.backgroundColor = AppColors.appWhiteColor
        self.informationVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "InformationVC") as! InformationVC
        
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
        
        // PROFILE SECTION
        profileSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        profileSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        profileImageView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        ratingView.settings.updateOnTouch = false
        ratingView.settings.fillMode = .precise
        btnSeeChefReviews.setTitle("see chef's reviews".getLocalizedString(), for: .normal)
        
        // SOCIAL MEDIA ACCOUNTS SECTION
        socialAccountsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        socialAccountsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblSocialAccountsSectionTitle.text = "Social Media Accounts".getLocalizedString()
        
        // BIOGRAPHY SECTION
        biographySectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        biographySectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblBiographySectionTitle.text = "Biography".getLocalizedString()
        
        // CHEF'S BEST MEALS SECTION
        chefBestMealsSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        chefBestMealsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblChefBestMealsSectionTitle.text = "Chef's Best Meals".getLocalizedString()
        tableBestMeals.delegate = self
        tableBestMeals.dataSource = self
        tableBestMeals.tableFooterView = UIView(frame: .zero)
        
        // KITCHEN INFORMATION SECTION
        kitchenInformationSectionView.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        kitchenInformationSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        lblKitchenInformationSectionTitle.text = "Chef's Kitchen Information".getLocalizedString()
        
        configureUIForCurrentUser()
    }
    
    private func configureUIForCurrentUser(){
        customizeNavBarForCurrentUser()
        btnClose.isHidden = true
        configurePageWithUserInformations()
    }
    
    private func configureUIForAnyUser(){
        customizeNavBarForAnyUser()
        btnClose.isHidden = false
        configurePageWithUserInformations()
    }
    
    private func configurePageWithUserInformations(){
        guard let user = self.user else {return}
        DispatchQueue.main.async {
            if let profileImageUrl = user.profileImageUrl {
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl, defaultImage: AppIcons.profileIcon)
            }else{
                self.profileImageView.image = AppIcons.profileIcon
            }
            
            self.lblChefName.text = user.name
            self.ratingView.rating = user.rating
            
            // TODO: CONFIGURE SOCIAL ACCOUNTS
            
            self.tvBiography.text = user.biography
            self.bestMeals = user.bestMeals ?? []
            self.kitchenLocation = user.kitchenInformation.getKitchenLocationAsCLLocationCoordinate2D()
            self.tvKitchenAddressDescription.text = user.kitchenInformation.addressDescription
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
        
        let contactUsViaMailAction = UIAlertAction(title: "Contact Us".getLocalizedString(), style: .default) { (action) in
            self.contactUsViaMail()
        }
        
        let goToProfileSettingsAction = UIAlertAction(title: "Go to Profile Settings".getLocalizedString(), style: .default) { (action) in
            self.goToProfileSettings()
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

// INFORMATION VIEW METHODS
extension ChefProfileVC {
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

// SHOW OPTIONS
extension ChefProfileVC {
    func setShowProperties(isShownForCurrentUser:Bool, chef:Chef? ,chefId:String?){
        if isShownForCurrentUser {
            if let currentUser = AppDelegate.shared.currentUserAsChef {
                self.user = currentUser
                configureUIForCurrentUser()
            }
        }else{
            if let chef = chef {
                self.user = chef
                configureUIForAnyUser()
            }
            
            if let chefId = chefId {
                self.showInformationView(withMessage: "Chef getiriliyor bekleyiniz".getLocalizedString(), showAsLoadingPage: true)
                self.getUserByUserId(chefId) { (chef) in
                    if let chef = chef {
                        self.user = chef
                        self.configureUIForAnyUser()
                    }else{
                        self.changeInformationView(withMessage: "Chef bulunamadı".getLocalizedString(), shouldAnimating: false)
                    }
                }
            }
        }
    }
}

// FIRABASE OPERATIONS
extension ChefProfileVC {
    private func getUserByUserId(_ userId:String){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("chefs/\(userId)").observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = Chef(dictionary: dictionary)
                    self.user = user
                }
            }
        }else{
            DispatchQueue.main.async {
                AlertService.showNoInternetConnectionErrorAlert(in: self)
            }
        }
    }
    
    // NOT IN USE
    private func getUserByUserId(_ userId:String, completion: @escaping (Chef?) -> Void){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("chefs/\(userId)").observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = Chef(dictionary: dictionary)
                    completion(user)
                }else{
                    completion(nil)
                }
            }
        }else{
            DispatchQueue.main.async {
                AlertService.showNoInternetConnectionErrorAlert(in: self)
            }
        }
    }
}

// SETTINGS SECTION
extension ChefProfileVC {
    @objc func contactUsViaMail() {
        guard let emailActionSheet = chooseEmailActionSheet else{
            return
        }
        
        let developerMail = "aakcura2001@gmail.com"
        let mailsubject = "HomeMeal - Contact".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "HomeMeal"
        let deviceAndAppInfo = DeviceAndAppInfo.init()
        let mailBody = "\n\n\nHomeMeal v\(deviceAndAppInfo.applicationVersionNumber ?? "") - \(deviceAndAppInfo.deviceModel)\(deviceAndAppInfo.deviceOSName) \(deviceAndAppInfo.deviceOSVersionName)".addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        
        let appleMailURL = "mailto:\(developerMail)?subject=\(mailsubject)&body=\(mailBody)"
        let gmailURL = "googlegmail://co?to=\(developerMail)&subject=\(mailsubject)&body=\(mailBody)"
        let outlookURL = "ms-outlook://compose?to=\(developerMail)&subject=\(mailsubject)&body=\(mailBody)"
        
        
        if let action = openAction(withURL: appleMailURL, andTitleActionTitle: "Through Mail".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: gmailURL, andTitleActionTitle: "Through Gmail".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: outlookURL, andTitleActionTitle: "Through Outlook".getLocalizedString()) {
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
        guard let user = self.user else { return }
        let profileSettingsVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "ChefProfileEditVC") as! ChefProfileEditVC
        profileSettingsVC.chef = user
        let profileSettingsNavigationController = UINavigationController(rootViewController: profileSettingsVC)
        self.present(profileSettingsNavigationController, animated: true, completion: nil)
    }
}

// TABLE VIEW
extension ChefProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bestMeals.isEmpty {
            return 1
        }else{
            return bestMeals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bestMeals.isEmpty {
            let emptyFavoriteMealCell = UITableViewCell()
            emptyFavoriteMealCell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
            emptyFavoriteMealCell.backgroundColor = .white
            emptyFavoriteMealCell.textLabel?.numberOfLines = 0
            emptyFavoriteMealCell.textLabel?.textAlignment = .center
            emptyFavoriteMealCell.textLabel?.text = "En iyi yemeğiniz bulunmamaktadır ..."
            return emptyFavoriteMealCell
        }else{
            let cell = UITableViewCell()
            cell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
            cell.backgroundColor = AppColors.appGoldColor
            let myBestMeal = bestMeals[indexPath.row]
            cell.textLabel?.text = myBestMeal
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if bestMeals.isEmpty{
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
        bestMeals.remove(at: indexPath.row)
        tableView.reloadData()
    }
}
