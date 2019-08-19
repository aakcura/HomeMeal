//
//  CustomerSignUpVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Validator
import Firebase
import FlagPhoneNumber

class CustomerSignUpVC: UIViewController, ActivityIndicatorDisplayProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var lblChooseProfilePhoto: UILabel!
    @IBOutlet weak var lblUserInfoStackTitle: UILabel!
    @IBOutlet weak var lblPasswordStackTitle: UILabel!
    @IBOutlet weak var lblPasswordValidationInfo: UILabel!
    @IBOutlet weak var lblBiographyStackTitle: UILabel!
    @IBOutlet weak var lblSocialMediaAccountsStackTitle: UILabel!
    @IBOutlet weak var lblLinkedin: UILabel!
    @IBOutlet weak var lblTwitter: UILabel!
    @IBOutlet weak var lblInstagram: UILabel!
    @IBOutlet weak var lblPinterest: UILabel!
    @IBOutlet weak var lblAllergiesStackTitle: UILabel!
    @IBOutlet weak var lblFavoriteMealsStackTitle: UILabel!
    
    @IBOutlet weak var stackUserInfo: UIStackView!
    @IBOutlet weak var stackPassword: UIStackView!
    @IBOutlet weak var stackBiography: UIStackView!
    @IBOutlet weak var stackSocialMediaAccounts: UIStackView!
    @IBOutlet weak var stackAllergies: UIStackView!
    @IBOutlet weak var stackFavoriteMeals: UIStackView!
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhoneNumber: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfPasswordConfirm: UITextField!
    @IBOutlet weak var tfLinkedin: UITextField!
    @IBOutlet weak var tfTwitter: UITextField!
    @IBOutlet weak var tfInstagram: UITextField!
    @IBOutlet weak var tfPinterest: UITextField!
    @IBOutlet weak var tfAllergy: UITextField!
    @IBOutlet weak var tfFavoriteMeal: UITextField!
    
    @IBOutlet weak var tvBiography: UITextView!
    @IBOutlet weak var tvTermsAndDataPolicy: UITextView!
    
    @IBOutlet weak var tableAllergies: UITableView!
    @IBOutlet weak var tableFavoriteMeals: UITableView!
    
    @IBOutlet weak var btnAddAllergy: UIButton!
    @IBOutlet weak var btnAddFavoriteMeal: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    var allergies: [String] = []
    var favoriteMeals: [String] = []

    var phoneNumber = ""
    var isNameValid:Bool = false
    var isEmailValid:Bool = false
    var isPhoneNumberValid: Bool = false
    var isPasswordValid:Bool = false
    var isPasswordConfirmed:Bool = false
    let emailValidationRule = ValidationRulePattern(pattern: EmailValidationPattern.simple, error: MyValidationErrors.emailInvalid)
    let passwordValidationRule = PasswordValidationRule(error: MyValidationErrors.passwordInvalid)
    let nameValidationRule = DefaultTextValidationRule(error: MyValidationErrors.nameInvalid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarTitle("Sign Up As Customer".getLocalizedString())
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        profileImageView.setCornerRadius(radiusValue: 20.0, makeRoundCorner: true)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfilePhotoSelect)))
        lblChooseProfilePhoto.text = "Choose profile photo".getLocalizedString()
        lblUserInfoStackTitle.text = "User Info".getLocalizedString()
        lblPasswordStackTitle.text = "Password".getLocalizedString()
        lblPasswordValidationInfo.text = ""
        lblBiographyStackTitle.text = "Biography".getLocalizedString()
        lblSocialMediaAccountsStackTitle.text = "Social Media Accounts".getLocalizedString()
        lblAllergiesStackTitle.text = "AllergiesStackTitle".getLocalizedString()
        lblFavoriteMealsStackTitle.text = "FavoriteMealsStackTitle".getLocalizedString()

        tfName.placeholder = "Name".getLocalizedString()
        tfName.delegate = self
        tfName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tfEmail.placeholder = "Email".getLocalizedString()
        tfEmail.delegate = self
        tfEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tfPhoneNumber.delegate = self
        
        tfPassword.placeholder = "Password".getLocalizedString()
        tfPassword.delegate = self
        tfPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        tfPasswordConfirm.placeholder = "Confirm Password".getLocalizedString()
        tfPasswordConfirm.delegate = self
        tfPasswordConfirm.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        tfPasswordConfirm.isEnabled = false
        
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
        
        let termsAndDataPolicyText = NSMutableAttributedString(string: "TermsAndDataPolicyText".getLocalizedString())
        termsAndDataPolicyText.addCustomAttributes(fontSize: 18, color: .black)
        let range: NSRange = termsAndDataPolicyText.mutableString.range(of: "$", options: .caseInsensitive)
        let termsAndDataPolicyLinkText = NSAttributedString(string: "Terms, and Data Policy".getLocalizedString(), attributes: [NSAttributedString.Key.link : "Terms, and Data Policy URL".getLocalizedString(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
        termsAndDataPolicyText.replaceCharacters(in: range, with: termsAndDataPolicyLinkText)
        tvTermsAndDataPolicy.attributedText = termsAndDataPolicyText
        
        btnSignUp.translatesAutoresizingMaskIntoConstraints = false
        btnSignUp.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnSignUp.setTitle("Sign Up".getLocalizedString(), for: .normal)

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
    
    @IBAction func addAllergyTapped(_ sender: Any) {
        insertNewAllergy()
    }
    
    
    @IBAction func addFavoriteMealTapped(_ sender: Any) {
        insertNewFavoriteMeal()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        print("Sign Up tapped")
        if isNameValid && isEmailValid && isPhoneNumberValid && isPasswordValid && isPasswordConfirmed {
            if NetworkManager.isConnectedNetwork(){
                signUp()
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

// HANDLE SIGN UP
extension CustomerSignUpVC{
    private func signUp(){
        guard let name = tfName.text, let email = tfEmail.text, let phoneNumber = (tfPhoneNumber as! FPNTextField).getFormattedPhoneNumber(format: .E164), let password = tfPasswordConfirm.text else {
            DispatchQueue.main.async { [weak self] in
                AlertService.showAlert(in: self, message: "Name, mail, phone, password, biography, kitchen information  can not be empty".getLocalizedString(), title: "", style: .alert)
            }
            return
        }
        
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
        let profileImage = profileImageView.image == AppIcons.addPhoto ? nil : profileImageView.image
        
        var values = [
            "allergies": allergies,
            "biography": biography,
            "email": email,
            "favoriteMeals": favoriteMeals,
            "name": name,
            "phoneNumber": phoneNumber,
            "socialAccounts": socialAccounts
            ] as [String: AnyObject]
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let authResult = authResult {
                values["userId"] = authResult.user.uid as AnyObject
                if let profilePhoto = profileImage, let uploadData = profilePhoto.jpegData(compressionQuality: 0.1) {
                    let storageRef = Storage.storage().reference().child("profile_images").child("\(authResult.user.uid).jpg")
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if let error = error {
                            // TODO: Error handling
                            self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                            return
                        }
                        storageRef.downloadURL(completion: { (url, error) in
                            guard let downloadURL = url else{
                                // TODO: Error handling
                                self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                                return
                            }
                            values["profileImageUrl"] =  downloadURL.absoluteString as AnyObject
                            self?.registerCustomerData(with: values)
                        })
                    })
                }else{
                    self?.registerCustomerData(with: values)
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    AlertService.showAlert(in: self, message: error!.localizedDescription, title: "Error".getLocalizedString(),style: .alert)
                }
            }
        }
    }
    
    private func registerCustomerData(with values: [String: AnyObject]){
        if NetworkManager.isConnectedNetwork() {
            let dbRef = Database.database().reference()
            guard let userId = values["userId"] as? String else {
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
                AlertService.showAlert(in: self, message: "An Error Occurred, Try Again".getLocalizedString(), title: "", buttonTitle: "OK".getLocalizedString(), style: .alert, dismissVCWhenButtonClicked: true, isVCInNavigationStack: true)
                return
            }
            dbRef.child("customers").child(userId).setValue(values) {[weak self] (error, databaseRef) in
                if let error = error {
                    // TODO: Error handling
                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                     AlertService.showAlert(in: self, message: error.localizedDescription, title:"", style: .alert)
                    return
                }else{
                    let accountInfo = [
                        "accountType": AccountType.customer.rawValue,
                        "accountStatus": AccountStatus.enabled.rawValue,
                        "creationDate": Date.init().timeIntervalSince1970
                        ] as [String : Any]
                    let accountValues = ["accountInfo": accountInfo] as [String:AnyObject]
                    dbRef.child("users").child(userId).setValue(accountValues, withCompletionBlock: { (error, databaseRef) in
                        if let error = error {
                            // TODO: Error handling
                            self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                            AlertService.showAlert(in: self, message:error.localizedDescription, title:"", style: .alert)
                            return
                        }else{
                            if let authUser = Auth.auth().currentUser {
                                authUser.sendEmailVerification(completion: { (error) in
                                    if let error = error {
                                        DispatchQueue.main.async { [weak self] in
                                            self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                                            AlertService.showAlert(in: self, message: error.localizedDescription, title: "Account Creation Successful, Verification Email Not Sent".getLocalizedString(), buttonTitle: "OK".getLocalizedString(), style: .alert, dismissVCWhenButtonClicked: true, isVCInNavigationStack: true)
                                        }
                                    }else{
                                        DispatchQueue.main.async { [weak self] in
                                            self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                                            AlertService.showAlert(in: self, message: "Account Creation Successful, Verification Email Sent".getLocalizedString(), title: "", buttonTitle: "OK".getLocalizedString(), style: .alert, dismissVCWhenButtonClicked: true, isVCInNavigationStack: true)
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
            
            
        }else{
            DispatchQueue.main.async { [weak self] in
                self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
            }
        }
    }
}

// TEXT FIELD
extension CustomerSignUpVC: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == tfName.tag {
            guard let name = tfName.text else {return}
            isNameValid = name.validate(rule: nameValidationRule).isValid
            if isNameValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfName.backgroundColor = nil
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfName.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                }
            }
        }
        
        if textField.tag == tfEmail.tag {
            guard let email = tfEmail.text else {return}
            isEmailValid = email.validate(rule: emailValidationRule).isValid
            if isEmailValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfEmail.backgroundColor = nil
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfEmail.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                }
            }
        }
        
        if textField.tag == tfPassword.tag {
            guard let password = tfPassword.text else {return}
            isPasswordValid = password.validate(rule: passwordValidationRule).isValid
            if isPasswordValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfPasswordConfirm.isEnabled = true
                    self?.tfPassword.backgroundColor = AppColors.appGreenColor
                    self?.lblPasswordValidationInfo.text = ""
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfPasswordConfirm.isEnabled = false
                    self?.tfPasswordConfirm.text = ""
                    self?.tfPasswordConfirm.backgroundColor = nil
                    self?.isPasswordConfirmed = false
                    self?.tfPassword.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.lblPasswordValidationInfo.text = MyValidationErrors.passwordInvalid.message
                }
            }
        }
        
        if textField.tag == tfPasswordConfirm.tag {
            guard let passwordConfirmation = tfPasswordConfirm.text, let password = tfPassword.text else {return}
            isPasswordConfirmed = passwordConfirmation == password //? true : false
            if isPasswordConfirmed {
                DispatchQueue.main.async { [weak self] in
                    self?.tfPasswordConfirm.backgroundColor = AppColors.appGreenColor
                    self?.lblPasswordValidationInfo.text = ""
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfPasswordConfirm.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.lblPasswordValidationInfo.text = "Şifre eşleşmiyor"
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case tfName.tag,tfEmail.tag,tfLinkedin.tag,tfTwitter.tag,tfInstagram.tag,tfPinterest.tag,tfAllergy.tag,tfFavoriteMeal.tag:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        case tfPassword.tag,tfPasswordConfirm.tag:
            return updatedText.count <= AppConstants.passwordMaxLength
        default:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        }
    }
    
}

// TEXT VIEW
extension CustomerSignUpVC: UITextViewDelegate {
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
extension CustomerSignUpVC: UITableViewDelegate, UITableViewDataSource {
    
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
extension CustomerSignUpVC: FPNTextFieldDelegate {
    
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
extension CustomerSignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
