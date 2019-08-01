//
//  CustomerSignUpVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Validator
import Firebase

class CustomerSignUpVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileInfoStack: UIStackView!
    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var allergiesStack: UIStackView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameAndMailStack: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordStackTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var allergiesStackTitleLabel: UILabel!
    @IBOutlet weak var allergiesTextView: UITextView!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    //let rangeLengthRule = ValidationRuleLength(min: 5, max: 10, error: )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarTitle("Sign Up As Customer".getLocalizedString())
        setupUIProperties()
    }
    
    func setupUIProperties(){
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.isUserInteractionEnabled = true
        profileImage.setCornerRadius(radiusValue: 20.0, makeRoundCorner: true)
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfilePhotoSelect)))
        nameTextField.placeholder = "Name".getLocalizedString()
        emailTextField.placeholder = "Email".getLocalizedString()
        passwordTextField.placeholder = "Password".getLocalizedString()
        passwordConfirmTextField.placeholder = "Confirm Password".getLocalizedString()
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordConfirmTextField.delegate = self
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        allergiesTextView.text = "AllergiesPlaceholderText".getLocalizedString()
        allergiesTextView.textColor = AppColors.textViewPlaceHolderColor
        allergiesTextView.delegate = self
        allergiesTextView.translatesAutoresizingMaskIntoConstraints = false
        allergiesTextView.setCornerRadius(radiusValue: 5.0)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        signUpButton.setTitle("Sign Up".getLocalizedString(), for: .normal)
        passwordStackTitleLabel.text = "Password".getLocalizedString()
        allergiesStackTitleLabel.text = "Allergies".getLocalizedString()
        passwordValidationLabel.text = ""
        activityIndicator.stopAnimating()
    }
    
    @objc func handleProfilePhotoSelect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    var isPassConfirmed:Bool = false
    var isMailValid:Bool = false
    var isNameValid:Bool = false
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.simple, error: ValidationErrors.emailInvalid)
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 1000 {
            if let name = nameTextField.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                DispatchQueue.main.async { [weak self] in
                    self?.nameTextField.backgroundColor = nil
                    self?.isNameValid = true
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.nameTextField.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isNameValid = false
                }
            }
        }
        
        if textField.tag == 1001 {
            let isMailValid = emailTextField.text!.validate(rule: emailRule)
            if isMailValid.isValid {
                DispatchQueue.main.async { [weak self] in
                    self?.emailTextField.backgroundColor = nil
                    self?.isMailValid = true
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.emailTextField.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isMailValid = false
                }
            }
        }
        
        if textField.tag == 1002 || textField.tag == 1003 {
            if let confirmPass = passwordConfirmTextField.text, let password = passwordTextField.text, !confirmPass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if confirmPass != password {
                    DispatchQueue.main.async { [weak self] in
                        //self?.passwordValidationLabel.isHidden = false
                        self?.passwordValidationLabel.text = "Şifreniz eşleşmiyor, kontrol ediniz"
                        self?.passwordConfirmTextField.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                        self?.isPassConfirmed = false
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        self?.passwordValidationLabel.text = ""
                        //self?.passwordValidationLabel.isHidden = true
                        self?.passwordConfirmTextField.backgroundColor = AppColors.appGreenColor//.withAlphaComponent(0.5)
                        self?.isPassConfirmed = true
                    }
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    //self?.passwordValidationLabel.isHidden = false
                    self?.passwordValidationLabel.text = "Şifreniz eşleşmiyor, kontrol ediniz"
                    self?.passwordConfirmTextField.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isPassConfirmed = false
                }
            }
        }
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        self.activityIndicator.startAnimating()
        if isNameValid && isMailValid && isPassConfirmed {
            let name = nameTextField.text!
            let email = emailTextField.text!
            let password = passwordConfirmTextField.text!
            let allergiesText = allergiesTextView.text == "AllergiesPlaceholderText".getLocalizedString() ? nil : allergiesTextView.text
            
            if NetworkManager.isConnectedNetwork() {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
                    if let authResult = authResult{
                        if let profilePhoto = self?.profileImage.image, profilePhoto != AppIcons.addPhoto, let uploadData = profilePhoto.jpegData(compressionQuality: 0.1){
                            let storageRef = Storage.storage().reference().child("profile_images").child("\(authResult.user.uid).jpg")
                            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                if let error = error {
                                    // TODO: Error handling
                                    return
                                }
                                storageRef.downloadURL(completion: { (url, error) in
                                    guard let downloadURL = url else{
                                        // TODO: Error handling
                                        return
                                    }
                                    var values = [
                                        "email": email,
                                        "name": name,
                                        "userId": authResult.user.uid,
                                        "profileImageUrl": downloadURL.absoluteString
                                        ] as [String: AnyObject]
                                    if allergiesText != nil {
                                        values["allergies"] = allergiesText! as AnyObject
                                    }
                                    self?.registerCustomerData(with: values)
                                })
                            })
                        }else{
                            var values = [
                                "email": email,
                                "name": name,
                                "userId": authResult.user.uid
                                ] as [String: AnyObject]
                            if allergiesText != nil {
                                values["allergies"] = allergiesText! as AnyObject
                            }
                            self?.registerCustomerData(with: values)
                        }
                    }else{
                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicator.stopAnimating()
                            AlertService.showAlert(in: self, message: error!.localizedDescription, title: "Error".getLocalizedString(), buttonTitle: "OK".getLocalizedString(), style: .alert, dismissVCWhenButtonClicked: true, isVCInNavigationStack: true)
                        }
                    }
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    AlertService.showAlert(in: self, message: "NoInternetConnectionErrorMessage".getLocalizedString(), title: "NoInternetConnectionError".getLocalizedString(), style: .alert)
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                AlertService.showAlert(in: self, message: "Gerekli alanları doldurmadan hesap oluşturulamaz", title: "", style: .alert)
            }
        }
    }

    private func registerCustomerData(with values: [String: AnyObject]){
        if NetworkManager.isConnectedNetwork() {
            let dbRef = Database.database().reference()
            dbRef.child("customers").child(values["userId"] as! String).setValue(values) {[weak self] (error, databaseRef) in
                if let error = error {
                    // TODO: Error handling
                    return
                }else{
                    DispatchQueue.main.async { [weak self] in
                        AlertService.showAlert(in: self, message: "Hesabınız başarı ile oluşturuldu, lütfen giriş yapınız", title: "", buttonTitle: "OK".getLocalizedString(), style: .alert, dismissVCWhenButtonClicked: true, isVCInNavigationStack: true)
                    }
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                AlertService.showAlert(in: self, message: "NoInternetConnectionErrorMessage".getLocalizedString(), title: "NoInternetConnectionError".getLocalizedString(), style: .alert)
            }
        }
    }
}

extension CustomerSignUpVC: UITextViewDelegate, UITextFieldDelegate{
    // TEXT FIELD METHODS
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case 1000,1001:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        case 1002,1003:
            return updatedText.count <= AppConstants.passwordCharacterCountLimit
        default:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        }
    }
    // END TEXT FIELD METHODS
    
    // TEXT VIEW METHODS
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.allergiesTextView.textColor == AppColors.textViewPlaceHolderColor {
            self.allergiesTextView.text = nil
            self.allergiesTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.allergiesTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            self.allergiesTextView.text = "AllergiesPlaceholderText".getLocalizedString()
            self.allergiesTextView.textColor = AppColors.textViewPlaceHolderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else{ return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= AppConstants.biographyCharacterCountLimit
    }
    // END TEXT VIEW METHODS
}

extension CustomerSignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
