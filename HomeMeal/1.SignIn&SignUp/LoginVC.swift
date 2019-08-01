//
//  LoginVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Validator
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordValidationLbl: UILabel!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    var signUpOptionsBackgroundView: SignUpOptionsBackgroundView!
    let signUpAsChefBtn: ImageButton = {
        let button = ImageButton(type: .system)
        button.setImageButtonProperties(buttonImage: AppIcons.chefIcon, buttonTitle: "As Chef".getLocalizedString(), buttonBackgroundColor: AppColors.appGoldColor, textColor: .black)
        return button
    }()
    let signUpAsCustomerBtn: ImageButton = {
        let button = ImageButton(type: .system)
        button.setImageButtonProperties(buttonImage: AppIcons.customerIcon, buttonTitle: "As Customer".getLocalizedString(), buttonBackgroundColor: AppColors.appYellowColor, textColor: .black)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        setupUIProperties()
        setupSignUpOptionsView()
    }
    
    func setupUIProperties(){
        emailTf.translatesAutoresizingMaskIntoConstraints = false
        passwordTf.translatesAutoresizingMaskIntoConstraints = false
        emailTf.delegate = self
        emailTf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        passwordTf.delegate = self
        passwordTf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        emailTf.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        passwordTf.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        let placeHolderAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        let emailTFPlaceHolderText = NSAttributedString(string: "Email".getLocalizedString(), attributes: placeHolderAttributes)
        let passwordTFPlaceHolderText = NSAttributedString(string: "Password".getLocalizedString(), attributes: placeHolderAttributes)
        emailTf.attributedPlaceholder = emailTFPlaceHolderText
        passwordTf.attributedPlaceholder = passwordTFPlaceHolderText
        emailTf.font = UIFont.boldSystemFont(ofSize: 18)
        passwordTf.font = UIFont.boldSystemFont(ofSize: 18)
        emailTf.textColor = UIColor.white
        passwordTf.textColor = UIColor.white
        forgotPasswordBtn.setTitle("Forgot password?".getLocalizedString(), for: .normal)
        signInBtn.setTitle("Sign In".getLocalizedString(), for: .normal)
        signUpBtn.setTitle("Sign Up".getLocalizedString(), for: .normal)
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        signInBtn.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        signUpBtn.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        passwordValidationLbl.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBar(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideNavBar(false, animated: animated)
    }
    
    @IBAction func forgotPasswordBtnClicked(_ sender: Any) {
        print("forgotPasswordBtnClicked")
        let forgotPasswordAlert = UIAlertController(title: "Forgot Password".getLocalizedString(), message: "Enter your email".getLocalizedString(), preferredStyle: .alert)
        forgotPasswordAlert.addTextField(configurationHandler: { [weak self] (emailTF:UITextField) in
            emailTF.placeholder = "Email".getLocalizedString()
            emailTF.textColor = UIColor.black
            emailTF.delegate = self
        })
        let resetAction = UIAlertAction(title: "Reset".getLocalizedString(), style: .destructive) { [weak self] (action) in
            if let email = forgotPasswordAlert.textFields![0].text {
                if !email.isEmpty && !email.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    Auth.auth().sendPasswordReset(withEmail: email) { error in
                        if let error = error {
                            // TODO: Error handling
                            print(error.localizedDescription)
                            return
                        }
                    }
                }else{
                    AlertService.showAlert(in: self, message: "Email not entered".getLocalizedString(), title: "", style: .actionSheet)
                }
            }else{
                AlertService.showAlert(in: self, message: "Email not entered".getLocalizedString(), title: "", style: .actionSheet)
            }
        }
        let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        forgotPasswordAlert.addAction(closeAction)
        forgotPasswordAlert.addAction(resetAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(forgotPasswordAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signInBtnClicked(_ sender: Any) {
        self.activityIndicator.startAnimating()
        if isMailValid && isPassValid {
            if NetworkManager.isConnectedNetwork() {
                let email = emailTf.text!
                let password = passwordTf.text!
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
                    if let authResult = authResult {
                        let dbRef = Database.database().reference().child("sessions").child(authResult.user.uid)
                        guard let sessionKey = dbRef.childByAutoId().key else{
                            // TODO: Error handling
                            return
                        }
                        
                        let device = DeviceAndAppInfo()
                        let deviceAndAppInfo = [
                            "deviceOSName": device.deviceOSName,
                            "deviceOSVersionName": device.deviceOSVersionName,
                            "deviceModel": device.deviceModel,
                            "deviceName": device.deviceName,
                            "applicationVersionNumber": device.applicationVersionNumber
                            ] as [String: AnyObject]
                        
                        let values = [
                            "startTime": Date().timeIntervalSince1970,
                            "status": SessionStatus.active.rawValue,
                            "deviceAndAppInfo": deviceAndAppInfo
                            ] as [String: AnyObject]
                        
                        dbRef.child(sessionKey).setValue(values, withCompletionBlock: { (error, databaseRef) in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self?.activityIndicator.stopAnimating()
                                    AlertService.showAlert(in: self, message: error.localizedDescription, title: "Error".getLocalizedString(), style: .alert)
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self?.activityIndicator.stopAnimating()
                                    // store the user session (example only, not for the production)
                                    UserDefaults.standard.set(sessionKey, forKey: UserDefaultsKeys.userSessionId)
                                    AppDelegate.shared.rootViewController.switchToMainScreen()
                                    // navigate to the Main Screen
                                }
                            }
                        })
                    }else{
                        DispatchQueue.main.async {
                            self?.activityIndicator.stopAnimating()
                            AlertService.showAlert(in: self, message: error!.localizedDescription, title: "Error".getLocalizedString(), style: .alert)
                        }
                    }
                }
            } else{
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stopAnimating()
                    AlertService.showAlert(in: self, message: "NoInternetConnectionErrorMessage".getLocalizedString(), title: "NoInternetConnectionError".getLocalizedString(), style: .alert)
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                AlertService.showAlert(in: self, message: "Geçersiz mail veya parola !", title: "", style: .alert)
            }
        }
    }
    
    
    @IBAction func signUpBtnClicked(_ sender: Any) {
        print("signUpBtnClicked")
        
        UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseInOut, animations: {
            self.signUpOptionsBackgroundView.isHidden = !self.signUpOptionsBackgroundView.isHidden
        }, completion: nil)
        
        //self.showSignUpOptions(shouldShow: true, animated: true)
    }

    
    func showSignUpOptions(shouldShow: Bool, animated: Bool){
        let alpha: CGFloat = (shouldShow ? 1 : 0)
        
        let animation = {
            DispatchQueue.main.async{
                self.signUpOptionsBackgroundView.alpha = alpha
            }
        }
        let completion = { (_: Bool) in
            if !shouldShow {
                DispatchQueue.main.async{
                    self.signUpOptionsBackgroundView.isHidden = true
                }
            }
        }
        if animated {
            DispatchQueue.main.async{
                UIView.animate(withDuration: 0.25, animations: animation, completion: completion)
            }
        } else {
            animation()
            completion(true)
        }
    }
    
    func setupSignUpOptionsView(){
        signUpOptionsBackgroundView = SignUpOptionsBackgroundView()
        signUpOptionsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        signUpOptionsBackgroundView.backgroundColor = .clear//AppColors.appOrangeColor
        view.addSubview(signUpOptionsBackgroundView)
        signUpOptionsBackgroundView.anchor(top: signUpBtn.bottomAnchor, leading: emailTf.leadingAnchor, trailing: emailTf.trailingAnchor, bottom: nil, centerX: nil, centerY: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .zero)
        signUpOptionsBackgroundView.heightAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        signUpAsCustomerBtn.addTarget(self, action: #selector(signUpAsCustomerBtnClicked), for: .touchUpInside)
        signUpAsChefBtn.addTarget(self, action: #selector(signUpAsChefBtnClicked), for: .touchUpInside)
        let signUpOptionsHSV = SignUpOptionsHSV()
        signUpOptionsHSV.setSignUpOptions(items: [signUpAsCustomerBtn,signUpAsChefBtn])
        signUpOptionsHSV.spacing = 25
        signUpOptionsBackgroundView.addSubview(signUpOptionsHSV)
        signUpOptionsHSV.anchor(top: signUpOptionsBackgroundView.topAnchor, leading: signUpOptionsBackgroundView.leadingAnchor, trailing: signUpOptionsBackgroundView.trailingAnchor, bottom: signUpOptionsBackgroundView.bottomAnchor, padding: .init(top: 25, left: 10, bottom: 10, right: 10), size: .zero)
        signUpOptionsBackgroundView.isHidden = true
    }
    
    @objc func signUpAsCustomerBtnClicked(){
        self.signUpOptionsBackgroundView.isHidden = true
        let customerSignUpVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "CustomerSignUpVC") as! CustomerSignUpVC
        navigationController?.pushViewController(customerSignUpVC, animated: true)
    }
    
    @objc func signUpAsChefBtnClicked(){
        self.signUpOptionsBackgroundView.isHidden = true
        //let chefSignUpVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "ChefSignUpVC") as! ChefSignUpVC
        let chefSignUpVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "CustomerSignUpVCTest") as! CustomerSignUpVCTest
        navigationController?.pushViewController(chefSignUpVC, animated: true)
    }
    
    var isPassValid:Bool = false
    var isMailValid:Bool = false
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.simple, error: ValidationErrors.emailInvalid)
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        if textField.tag == 1000 {
            let isMailValid = emailTf.text!.validate(rule: emailRule)
            if isMailValid.isValid {
                DispatchQueue.main.async { [weak self] in
                    self?.emailTf.backgroundColor = AppColors.appGreenColor//.withAlphaComponent(0.5)
                    self?.isMailValid = true
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.emailTf.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isMailValid = false
                }
            }
        }
        
        if textField.tag == 1001 {
            if let password = passwordTf.text, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                //print("Pass=\(password)\nTrimmed=\(password.trimmingCharacters(in: .whitespacesAndNewlines))")
                
                if password.count < 6 {
                    DispatchQueue.main.async { [weak self] in
                        //self?.passwordValidationLbl.isHidden = false
                        self?.passwordValidationLbl.text = "Şifreniz min 6 karakter olmalı ve boşluk içermemelidir"
                        self?.passwordTf.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                        self?.isPassValid = false
                    }
                }else{
                    DispatchQueue.main.async { [weak self] in
                        self?.passwordValidationLbl.text = ""
                        //self?.passwordValidationLbl.isHidden = true
                        self?.passwordTf.backgroundColor = AppColors.appGreenColor//.withAlphaComponent(0.5)
                        self?.isPassValid = true
                    }
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    //self?.passwordValidationLbl.isHidden = false
                    self?.passwordValidationLbl.text = "Şifre boş bırakılamaz"
                    self?.passwordTf.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                    self?.isPassValid = false
                }
            }
        }
    }
    
}

extension LoginVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case 1000:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        case 1001:
            return updatedText.count <= AppConstants.passwordCharacterCountLimit
        default:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        }
    }
}

class SignUpOptionsHSV: UIStackView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = .fillEqually
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSignUpOptions(items: [ImageButton]){
        for item in items {
            self.addArrangedSubview(item)
        }
    }
}


