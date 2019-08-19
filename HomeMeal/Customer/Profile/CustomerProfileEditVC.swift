//
//  CustomerProfileEditVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Validator
import Firebase
import FlagPhoneNumber

class CustomerProfileEditVC: UIViewController, ActivityIndicatorDisplayProtocol {
    
    @IBOutlet weak var btnClose: UIButton!
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
    @IBOutlet weak var lblAllergiesStackTitle: UILabel!
    @IBOutlet weak var lblFavoriteMealsStackTitle: UILabel!
    
    @IBOutlet weak var stackUserInfo: UIStackView!
    @IBOutlet weak var stackBiography: UIStackView!
    @IBOutlet weak var stackSocialMediaAccounts: UIStackView!
    @IBOutlet weak var stackAllergies: UIStackView!
    @IBOutlet weak var stackFavoriteMeals: UIStackView!
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfLinkedin: UITextField!
    @IBOutlet weak var tfTwitter: UITextField!
    @IBOutlet weak var tfInstagram: UITextField!
    @IBOutlet weak var tfPinterest: UITextField!
    @IBOutlet weak var tfAllergy: UITextField!
    @IBOutlet weak var tfFavoriteMeal: UITextField!
    
    @IBOutlet weak var tvBiography: UITextView!
    
    @IBOutlet weak var tableAllergies: UITableView!
    @IBOutlet weak var tableFavoriteMeals: UITableView!
    
    @IBOutlet weak var btnAddAllergy: UIButton!
    @IBOutlet weak var btnAddFavoriteMeal: UIButton!
    @IBOutlet weak var btnUpdateProfileInformation: UIButton!
    
    var allergies: [String] = []
    var favoriteMeals: [String] = []
    var oldPhoto: UIImage?
    var newPhoto: UIImage?
    
    var phoneNumber = ""
    var isPhoneNumberValid: Bool = false
    
    var customer: Customer! {
        didSet{
           self.configurePageWith(self.customer)
        }
    }
    
    private func configurePageWith(_ customer: Customer){
        DispatchQueue.main.async {
            if let customerProfileImage = customer.profileImage {
                self.profileImageView.image = customerProfileImage
            }else if let profileImageURL = customer.profileImageUrl {
                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL, defaultImage: AppIcons.addPhoto)
            }else{
                self.profileImageView.image = AppIcons.addPhoto
            }
            
            self.oldPhoto = self.profileImageView.image
            self.tfName.text = customer.name
            self.tfEmail.text = customer.email
            (self.tfPhoneNumber as! FPNTextField).set(phoneNumber: customer.phoneNumber)
            self.phoneNumber = customer.phoneNumber
            self.isPhoneNumberValid = true
            self.tvBiography.textColor = .black
            self.tvBiography.text = customer.biography
            if let socialAccountsList = customer.socialAccounts {
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
            self.allergies = customer.allergies ?? []
            self.tableAllergies.reloadData()
            self.favoriteMeals = customer.favoriteMeals ?? []
            self.tableFavoriteMeals.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarTitle("Profile Settings".getLocalizedString())
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        profileImageView.setCornerRadius(radiusValue: 20.0, makeRoundCorner: true)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfilePhotoSelect)))
        lblChooseProfilePhoto.text = "Choose profile photo".getLocalizedString()
        lblUserInfoStackTitle.text = "User Info".getLocalizedString()
        lblBiographyStackTitle.text = "Biography".getLocalizedString()
        lblSocialMediaAccountsStackTitle.text = "Social Media Accounts".getLocalizedString()
        lblAllergiesStackTitle.text = "AllergiesStackTitle".getLocalizedString()
        lblFavoriteMealsStackTitle.text = "FavoriteMealsStackTitle".getLocalizedString()
        
        tfName.isUserInteractionEnabled = false
        tfEmail.isUserInteractionEnabled = false
    
        tfPhoneNumber.delegate = self
        
        tvBiography.text = "BiographyPlaceHolder".getLocalizedString()
        tvBiography.textColor = AppColors.textViewPlaceHolderColor
        tvBiography.delegate = self
        tvBiography.translatesAutoresizingMaskIntoConstraints = false
        tvBiography.setCornerRadius(radiusValue: 5.0)
        
        tfLinkedin.placeholder = "LinkedinTFPlaceHolder".getLocalizedString()
        tfTwitter.placeholder = "TwitterTFPlaceHolder".getLocalizedString()
        tfInstagram.placeholder = "InstagramTFPlaceHolder".getLocalizedString()
        tfPinterest.placeholder = "PinterestTFPlaceHolder".getLocalizedString()
        
        tfAllergy.placeholder = "AllergyTFPlaceHolder".getLocalizedString()
        tfFavoriteMeal.placeholder = "FavoriteMealTFPlaceHolder".getLocalizedString()
        
        // Table lara ait olan delegate ve datasource lar storyboard üzerinden verildi.
        tableAllergies.tableFooterView = UIView(frame: .zero)
        tableFavoriteMeals.tableFooterView = UIView(frame: .zero)
        btnUpdateProfileInformation.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnUpdateProfileInformation.setTitle("Update".getLocalizedString(), for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func insertNewAllergy(){
        if let allergy = tfAllergy.text, !allergy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            allergies.append(allergy)
            tableAllergies.reloadData()
            tfAllergy.text = ""
            view.endEditing(true)
        }
    }
    
    private func insertNewFavoriteMeal(){
        if let favoriteMeal = tfFavoriteMeal.text, !favoriteMeal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            favoriteMeals.append(favoriteMeal)
            tableFavoriteMeals.reloadData()
            tfFavoriteMeal.text = ""
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
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAllergyTapped(_ sender: Any) {
        insertNewAllergy()
    }
    
    @IBAction func addFavoriteMealTapped(_ sender: Any) {
        insertNewFavoriteMeal()
    }
    
    @IBAction func updateTapped(_ sender: Any) {
        guard let phoneNumber = (tfPhoneNumber as! FPNTextField).getFormattedPhoneNumber(format: .E164) else {
            DispatchQueue.main.async { [weak self] in
                AlertService.showAlert(in: self, message: "Phone Number must be valid".getLocalizedString(), title: "", style: .alert)
            }
            return
        }
        
        if NetworkManager.isConnectedNetwork(){
            
            self.showActivityIndicatorView(isUserInteractionEnabled: false)
            
            let biography = tvBiography.text == "BiographyPlaceHolder".getLocalizedString() ? nil : tvBiography.text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\t", with: " ").replacingOccurrences(of: "\n", with: " ")
            
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
                "allergies": allergies,
                "biography": biography,
                "favoriteMeals": favoriteMeals,
                "phoneNumber": phoneNumber,
                "socialAccounts": socialAccounts
                ] as [String: AnyObject]
            if let profilePhoto = profileImage, let uploadData = profilePhoto.jpegData(compressionQuality: 0.1) {
                let storageRef = Storage.storage().reference().child("profile_images").child("\(customer.userId).jpg")
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
    }
}

// HANDLE UPDATE UP
extension CustomerProfileEditVC{
    private func updateProfile(with values: [String:AnyObject]){
        let profileRef = Database.database().reference().child("customers/\(customer.userId)")
        if NetworkManager.isConnectedNetwork() {
            profileRef.updateChildValues(values) { (error, databaseRef) in
                if error != nil {
                    self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    DispatchQueue.main.async {
                        AlertService.showAlert(in: self, message: "Customer Profile Update Failed".getLocalizedString(), title: "Error".getLocalizedString(), style: .alert, blockUI: false)
                    }
                    return
                }else{
                    self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    DispatchQueue.main.async {
                        let updateSuccessfulAlert = UIAlertController(title: nil, message: "Your profile information has been updated successfully".getLocalizedString(), preferredStyle: .alert)
                        let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: { (action) in
                            self.closeTapped(true)
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

// TEXT FIELD
extension CustomerProfileEditVC: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        switch textField.tag {
        case tfName.tag,tfEmail.tag,tfLinkedin.tag,tfTwitter.tag,tfInstagram.tag,tfPinterest.tag,tfAllergy.tag,tfFavoriteMeal.tag:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        default:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        }
    }
    
}

// TEXT VIEW
extension CustomerProfileEditVC: UITextViewDelegate {
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
}

// TABLE VIEW
extension CustomerProfileEditVC: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        if tableView == tableAllergies {
            allergies.remove(at: indexPath.row)
        }
        if tableView == tableFavoriteMeals {
            favoriteMeals.remove(at: indexPath.row)
        }
        //tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
}

// PHONE NUMBER TF
extension CustomerProfileEditVC: FPNTextFieldDelegate {
    
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
extension CustomerProfileEditVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
