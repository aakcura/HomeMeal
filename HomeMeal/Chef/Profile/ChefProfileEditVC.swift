//
//  ChefProfileEditVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Validator
import Firebase
import FlagPhoneNumber
import CoreLocation
import MapKit

class ChefProfileEditVC: UIViewController, ActivityIndicatorDisplayProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var lblChooseProfilePhoto: UILabel!
    @IBOutlet weak var lblUserInfoStackTitle: UILabel!
    @IBOutlet weak var lblBiographyStackTitle: UILabel!
    @IBOutlet weak var lblSocialMediaAccountsStackTitle: UILabel!
    @IBOutlet weak var lblLinkedin: UILabel!
    @IBOutlet weak var lblTwitter: UILabel!
    @IBOutlet weak var lblInstagram: UILabel!
    @IBOutlet weak var lblPinterest: UILabel!
    @IBOutlet weak var lblMyBestMealsStackTitle: UILabel!
    
    @IBOutlet weak var stackUserInfo: UIStackView!
    @IBOutlet weak var stackBiography: UIStackView!
    @IBOutlet weak var stackSocialMediaAccounts: UIStackView!
    @IBOutlet weak var stackMyBestMeals: UIStackView!
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfLinkedin: UITextField!
    @IBOutlet weak var tfTwitter: UITextField!
    @IBOutlet weak var tfInstagram: UITextField!
    @IBOutlet weak var tfPinterest: UITextField!
    @IBOutlet weak var tfBestMeal: UITextField!
    
    @IBOutlet weak var tvBiography: UITextView!
    @IBOutlet weak var lblBiographyCharacterCount: UILabel!
    @IBOutlet weak var tvTermsAndDataPolicy: UITextView!
    
    @IBOutlet weak var tableBestMeals: UITableView!
    
    @IBOutlet weak var btnAddBestMeal: UIButton!
    @IBOutlet weak var btnPickKitchenLocation: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    
    var bestMeals: [String] = []
    
    var chefKitchenInformation: KitchenInformation?  {
        didSet{
            if chefKitchenInformation != nil {
                btnPickKitchenLocation.setTitle(btnPickKitchenLocationSelectedTitle, for: .normal)
                btnPickKitchenLocation.backgroundColor = AppColors.appGreenColor
            }else{
                btnPickKitchenLocation.setTitle(btnPickKitchenLocationTitle, for: .normal)
                btnPickKitchenLocation.backgroundColor = AppColors.appOrangeColor
            }
        }
    }
    let btnPickKitchenLocationTitle = AppIcons.faSearchLocationSolid + " " + "Pick Your Kitchen Location".getLocalizedString()
    let btnPickKitchenLocationSelectedTitle = AppIcons.faMapMarkedAltSolid + " " + "See Your Kitchen Location".getLocalizedString()
    
    var biographyText: String? = nil
    var phoneNumber = ""
    var isPhoneNumberValid: Bool = false
    var isBiographyValid:Bool = false
    
    var oldPhoto: UIImage?
    
    var chef: Chef! {
        didSet{
            self.configurePageWith(self.chef)
        }
    }
    
    private func configurePageWith(_ chef: Chef){
        DispatchQueue.main.async {
            if let chefProfileImage = chef.profileImage {
                self.profileImageView.image = chefProfileImage
            }else if let profileImageURL = chef.profileImageUrl {
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL, defaultImage: AppIcons.addPhoto)
            }else{
                self.profileImageView.image = AppIcons.addPhoto
            }
            
            self.oldPhoto = self.profileImageView.image
            self.tfName.text = chef.name
            self.tfEmail.text = chef.email
            (self.tfPhoneNumber as! FPNTextField).set(phoneNumber: chef.phoneNumber)
            self.tvBiography.textColor = .black
            self.tvBiography.text = chef.biography
            if let socialAccountsList = chef.socialAccounts {
                for item in socialAccountsList {
                    switch item.accountType {
                    case .linkedin:
                        self.tfLinkedin.text = item.userName
                        break
                    case .twitter:
                        self.tfTwitter.text = item.userName
                        break
                    case .instagram:
                        self.tfInstagram.text = item.userName
                        break
                    case .pinterest:
                        self.tfPinterest.text = item.userName
                        break
                    }
                }
            }
            self.bestMeals = chef.bestMeals ?? []
            self.tableBestMeals.reloadData()
            self.chefKitchenInformation = chef.kitchenInformation
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        customizeNavBar()
        setupUIProperties()
    }
    
    private func customizeNavBar() {
        self.setNavBarTitle("Profile Settings".getLocalizedString())
        let backBarButtton = UIBarButtonItem(image: AppIcons.arrowLeftIcon, style: .plain, target: self, action: #selector(self.closeVC))
        navigationItem.leftBarButtonItem = backBarButtton
    }
    
    @objc func closeVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupUIProperties(){
        // Profile Image Stack
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        profileImageView.setCornerRadius(radiusValue: 20.0, makeRoundCorner: true)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfilePhotoSelect)))
        lblChooseProfilePhoto.text = "Choose profile photo".getLocalizedString()
        
        // User Info Stack
        lblUserInfoStackTitle.text = "User Info".getLocalizedString()
        tfName.isUserInteractionEnabled = false
        tfEmail.isUserInteractionEnabled = false
        tfPhoneNumber.delegate = self
        
        
        // Biography Stack
        lblBiographyStackTitle.text = "Biography".getLocalizedString()
        tvBiography.text = "BiographyPlaceHolder".getLocalizedString()
        tvBiography.textColor = AppColors.textViewPlaceHolderColor
        tvBiography.delegate = self
        tvBiography.translatesAutoresizingMaskIntoConstraints = false
        tvBiography.setCornerRadius(radiusValue: 5.0)
        
        // Social Media Accounts Stack
        lblSocialMediaAccountsStackTitle.text = "Social Media Accounts".getLocalizedString()
        tfLinkedin.placeholder = "LinkedinTFPlaceHolder".getLocalizedString()
        tfTwitter.placeholder = "TwitterTFPlaceHolder".getLocalizedString()
        tfInstagram.placeholder = "InstagramTFPlaceHolder".getLocalizedString()
        tfPinterest.placeholder = "PinterestTFPlaceHolder".getLocalizedString()
        
        // Best Meals Stack
        lblMyBestMealsStackTitle.text = "MyBestMealsStackTitle".getLocalizedString()
        tfBestMeal.placeholder = "BestMealTFPlaceHolder".getLocalizedString()
        tableBestMeals.delegate = self
        tableBestMeals.dataSource = self
        tableBestMeals.tableFooterView = UIView(frame: .zero)
        
        // Pick Kitchen Location
        btnPickKitchenLocation.translatesAutoresizingMaskIntoConstraints = false
        btnPickKitchenLocation.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        chefKitchenInformation = nil
        
        // Update
        btnUpdate.translatesAutoresizingMaskIntoConstraints = false
        btnUpdate.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnUpdate.setTitle("Update".getLocalizedString(), for: .normal)
        
        // View
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func insertNewBestMeal(){
        if let bestMeal = tfBestMeal.text, !bestMeal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bestMeals.append(bestMeal)
            tableBestMeals.reloadData()
            tfBestMeal.text = ""
            view.endEditing(true)
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
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func addBestMealTapped(_ sender: Any) {
        insertNewBestMeal()
    }
    
    
    @IBAction func pickKitchenLocationTapped(_ sender: Any) {
        let kitchenLocationPickerVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "KitchenLocationPickerVC") as! KitchenLocationPickerVC
        kitchenLocationPickerVC.kitchenInformationDelegate = self
        if chefKitchenInformation != nil {
            kitchenLocationPickerVC.kitchenInformation = chefKitchenInformation
        }
        self.navigationController?.pushViewController(kitchenLocationPickerVC, animated: true)
    }
    
    @IBAction func updateTapped(_ sender: Any) {
        if isPhoneNumberValid && isBiographyValid && chefKitchenInformation != nil {
            if NetworkManager.isConnectedNetwork(){
                guard let phoneNumber = (tfPhoneNumber as! FPNTextField).getFormattedPhoneNumber(format: .E164), let biography = biographyText, let chefKitchenInformation = chefKitchenInformation else {
                    DispatchQueue.main.async { [weak self] in
                        AlertService.showAlert(in: self, message: "İsim mail telefon şifre biografi ve mutfak bilgilerinden herhangi biri boş olamaz !!! ".getLocalizedString(), title: "", style: .alert)
                    }
                    return
                }
                
                self.showActivityIndicatorView(isUserInteractionEnabled: false)
                
                let linkedinUsername = tfLinkedin.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let twitterUsername = tfTwitter.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let instagramUsername = tfInstagram.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let pinterestUsername = tfPinterest.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let socialAccounts = [
                    "linkedin": linkedinUsername == "" ? nil : linkedinUsername,
                    "twitter": twitterUsername == "" ? nil : twitterUsername,
                    "instagram": instagramUsername == "" ? nil : instagramUsername,
                    "pinterest": pinterestUsername == "" ? nil : pinterestUsername
                ]
                let profileImage = (profileImageView.image == AppIcons.addPhoto || profileImageView.image == self.oldPhoto) ? nil : profileImageView.image
                
                var values = [
                    "bestMeals": bestMeals,
                    "biography": biography,
                    "kitchenInformation" : chefKitchenInformation.getDictionary(),
                    "phoneNumber": phoneNumber,
                    "socialAccounts": socialAccounts
                    ] as [String: AnyObject]
                if let profilePhoto = profileImage, let uploadData = profilePhoto.jpegData(compressionQuality: 0.1) {
                    let storageRef = Storage.storage().reference().child("profile_images").child("\(chef.userId).jpg")
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if let error = error {
                            // TODO: Error handling
                            self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                            return
                        }
                        storageRef.downloadURL(completion: { (url, error) in
                            guard let downloadURL = url else{
                                // TODO: Error handling
                                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                                return
                            }
                            values["profileImageUrl"] =  downloadURL.absoluteString as AnyObject
                            self.updateProfile(with: values)
                        })
                    })
                }else{
                    self.updateProfile(with: values)
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                AlertService.showAlert(in: self, message: "Gerekli alanları doldurmadan hesap oluşturulamaz", title: "", style: .alert)
            }
        }
    }
    
}


// HANDLE UPDATE
extension ChefProfileEditVC{
    private func updateProfile(with values: [String:AnyObject]){
        let profileRef = Database.database().reference().child("chefs/\(chef.userId)")
        if NetworkManager.isConnectedNetwork() {
            profileRef.updateChildValues(values) { (error, databaseRef) in
                if error != nil {
                    self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    DispatchQueue.main.async {
                        AlertService.showAlert(in: self, message: "Chef Profile update başarısız".getLocalizedString(), title: "Error".getLocalizedString(), style: .alert, blockUI: false)
                    }
                    return
                }else{
                    self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    DispatchQueue.main.async {
                        let updateSuccessfulAlert = UIAlertController(title: nil, message: "Your profile information has been updated successfully".getLocalizedString(), preferredStyle: .alert)
                        let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: { (action) in
                            self.closeVC()
                        })
                        updateSuccessfulAlert.addAction(closeAction)
                        self.present(updateSuccessfulAlert, animated: true, completion: nil)
                    }
                }
            }
        }else{
            self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            AlertService.showNoInternetConnectionErrorAlert(in: self)
        }
    }
}

// KITCHEN INFORMATION
extension ChefProfileEditVC: KitchenInformationDelegate{
    func confirmKitchenInformation(_ kitchenInformation: KitchenInformation) {
        self.chefKitchenInformation = kitchenInformation
    }
}

// TEXT FIELD
extension ChefProfileEditVC: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case tfLinkedin.tag,tfTwitter.tag,tfInstagram.tag,tfPinterest.tag,tfBestMeal.tag:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        default:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        }
    }
    
}

// TEXT VIEW
extension ChefProfileEditVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.tvBiography.textColor == AppColors.textViewPlaceHolderColor {
            self.tvBiography.text = nil
            self.tvBiography.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.tvBiography.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            self.tvBiography.text = "BiographyPlaceHolder".getLocalizedString()
            self.tvBiography.textColor = AppColors.textViewPlaceHolderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else{ return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= AppConstants.biographyCharacterCountLimit
    }
    
    // TEST
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == tvBiography.tag {
            let biography = tvBiography.text == "BiographyPlaceHolder".getLocalizedString() ? nil : tvBiography.text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ")
            if let biography = biography{
                lblBiographyCharacterCount.text = "\(biography.count)/ min 128"
                if biography.count >= 128 {
                    tvBiography.backgroundColor = nil
                    isBiographyValid = true
                    biographyText = biography
                }else{
                    tvBiography.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    isBiographyValid = false
                    biographyText = nil
                }
            }else{
                tvBiography.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                isBiographyValid = false
                biographyText = nil
            }
        }
    }
    
}

// TABLE VIEW
extension ChefProfileEditVC: UITableViewDelegate, UITableViewDataSource {
    
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

// PHONE NUMBER TF
extension ChefProfileEditVC: FPNTextFieldDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        //print(name, dialCode, code) // Output "France", "+33", "FR"
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        isPhoneNumberValid = isValid
        if isPhoneNumberValid {
            tfPhoneNumber.backgroundColor = nil
        }else{
            tfPhoneNumber.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
        }
    }
}

// IMAGE PICKER
extension ChefProfileEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func handleProfilePhotoSelect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
