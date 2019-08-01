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

class CustomerSignUpVCTest: UIViewController {
    
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
    @IBOutlet weak var lblFavoriteDishesStackTitle: UILabel!
    
    @IBOutlet weak var stackUserInfo: UIStackView!
    @IBOutlet weak var stackPassword: UIStackView!
    @IBOutlet weak var stackBiography: UIStackView!
    @IBOutlet weak var stackSocialMediaAccounts: UIStackView!
    @IBOutlet weak var stackAllergies: UIStackView!
    @IBOutlet weak var stackFavoriteDishes: UIStackView!
    
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
    @IBOutlet weak var tfFavoriteDish: UITextField!
    
    @IBOutlet weak var tvBiography: UITextView!
    @IBOutlet weak var tvTermsAndDataPolicy: UITextView!
    
    @IBOutlet weak var tableAllergies: UITableView!
    @IBOutlet weak var tableFavoriteDishes: UITableView!
    
    @IBOutlet weak var btnAddAllergy: UIButton!
    @IBOutlet weak var btnAddFavoriteDish: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    var allergies: [String] = []
    var favoriteDishes: [String] = []

    var isPassConfirmed:Bool = false
    var isMailValid:Bool = false
    var isNameValid:Bool = false
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.simple, error: ValidationErrors.emailInvalid)
    
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
        lblFavoriteDishesStackTitle.text = "FavoriteDishesStackTitle".getLocalizedString()

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
        tfFavoriteDish.placeholder = "FavoriteDishTFPlaceHolder".getLocalizedString()
        
        // Table lara ait olan delegate ve datasource lar storyboard üzerinden verildi.
        tableAllergies.tableFooterView = UIView(frame: .zero)
        tableFavoriteDishes.tableFooterView = UIView(frame: .zero)
        
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
        
        activityIndicator.stopAnimating()
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @IBAction func addAllergyTapped(_ sender: Any) {
        print("Add allergy tapped")
        insertNewAllergy()
    }
    
    
    @IBAction func addFavoriteDishTapped(_ sender: Any) {
         print("Add favorite dish tapped")
        insertNewFavoriteDish()
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        print("Sign Up tapped")
    }
    
    private func insertNewAllergy(){
        if let allergy = tfAllergy.text, !allergy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            allergies.append(allergy)
            tableAllergies.reloadData()
            tfAllergy.text = ""
            view.endEditing(true)
        }
    }
    
    private func insertNewFavoriteDish(){
        if let favoriteDish = tfFavoriteDish.text, !favoriteDish.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            favoriteDishes.append(favoriteDish)
            tableFavoriteDishes.reloadData()
            tfFavoriteDish.text = ""
            view.endEditing(true)
        }
    }
}

// TEXT FIELD
extension CustomerSignUpVCTest: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == tfName.tag {
            if let name = tfName.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                DispatchQueue.main.async { [weak self] in
                    self?.tfName.backgroundColor = nil
                    self?.isNameValid = true
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfName.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isNameValid = false
                }
            }
        }
        
        if textField.tag == tfEmail.tag {
            let isMailValid = tfEmail.text!.validate(rule: emailRule)
            if isMailValid.isValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfEmail.backgroundColor = nil
                    self?.isMailValid = true
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.tfEmail.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isMailValid = false
                }
            }
        }
        
        if textField.tag == tfPassword.tag || textField.tag == tfPasswordConfirm.tag{
            if let confirmPass = tfPasswordConfirm.text, let password = tfPassword.text, !confirmPass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if confirmPass != password {
                    DispatchQueue.main.async { [weak self] in
                        //self?.passwordValidationLabel.isHidden = false
                        self?.lblPasswordValidationInfo.text = "Şifreniz eşleşmiyor, kontrol ediniz"
                        self?.tfPasswordConfirm.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                        self?.isPassConfirmed = false
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        self?.lblPasswordValidationInfo.text = ""
                        //self?.passwordValidationLabel.isHidden = true
                        self?.tfPasswordConfirm.backgroundColor = AppColors.appGreenColor//.withAlphaComponent(0.5)
                        self?.isPassConfirmed = true
                    }
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    //self?.passwordValidationLabel.isHidden = false
                    self?.lblPasswordValidationInfo.text = "Şifreniz eşleşmiyor, kontrol ediniz"
                    self?.tfPasswordConfirm.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isPassConfirmed = false
                }
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case tfName.tag,tfEmail.tag,tfLinkedin.tag,tfTwitter.tag,tfInstagram.tag,tfPinterest.tag,tfAllergy.tag,tfFavoriteDish.tag:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        case tfPassword.tag,tfPasswordConfirm.tag:
            return updatedText.count <= AppConstants.passwordCharacterCountLimit
        default:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        }
    }
    
}

// TEXT VIEW
extension CustomerSignUpVCTest: UITextViewDelegate {
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
extension CustomerSignUpVCTest: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableAllergies {
            if allergies.isEmpty {
                return 1
            }else{
                return allergies.count
            }
        }
        
        if tableView == tableFavoriteDishes {
            if favoriteDishes.isEmpty {
                return 1
            }else{
                return favoriteDishes.count
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
                emptyAllergyCell.textLabel?.text = "Alerjiniz bulunmamaktadır."
                return emptyAllergyCell
            }else{
                let allergy = allergies[indexPath.row]
                cell.textLabel?.text = allergy
            }
        }
        
        if tableView == tableFavoriteDishes {
            if favoriteDishes.isEmpty {
                let emptyFavoriteDishCell = UITableViewCell()
                //emptyFavoriteDishCell.setBorder(borderWidth: 1, borderColor: .black)
                emptyFavoriteDishCell.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
                emptyFavoriteDishCell.backgroundColor = .white
                emptyFavoriteDishCell.textLabel?.numberOfLines = 0
                emptyFavoriteDishCell.textLabel?.textAlignment = .center
                emptyFavoriteDishCell.textLabel?.text = "Favori yemeğiniz bulunmamaktadır."
                return emptyFavoriteDishCell
            }else{
                let favoriteDish = favoriteDishes[indexPath.row]
                cell.textLabel?.text = favoriteDish
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
        if tableView == tableFavoriteDishes {
            if favoriteDishes.isEmpty{
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
        if tableView == tableFavoriteDishes {
            favoriteDishes.remove(at: indexPath.row)
        }
        
        //tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
    }
}

// PHONE NUMBER TF
extension CustomerSignUpVCTest: FPNTextFieldDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code) // Output "France", "+33", "FR"
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            // Do something...
            let phoneNumber = textField.getFormattedPhoneNumber(format: .E164) // Output "+33600000001"
        } else {
            // Do something...
        }
    }
}


// IMAGE PICKER
extension CustomerSignUpVCTest: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
