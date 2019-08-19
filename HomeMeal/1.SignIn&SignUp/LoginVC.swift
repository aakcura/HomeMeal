//
//  LoginVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Validator
import Firebase

class LoginVC: UIViewController, ActivityIndicatorDisplayProtocol {
   
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lblPasswordValidationInfo: UILabel!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    
    var signUpOptionsBackgroundView: SignUpOptionsBackgroundView!
    let btnSignUpAsChef: ImageButton = {
        let button = ImageButton(type: .system)
        button.setImageButtonProperties(buttonImage: AppIcons.chefIcon, buttonTitle: "As Chef".getLocalizedString(), buttonBackgroundColor: AppColors.appGreenColor, textColor: .black)
        return button
    }()
    let btnSignUpAsCustomer: ImageButton = {
        let button = ImageButton(type: .system)
        button.setImageButtonProperties(buttonImage: AppIcons.customerIcon, buttonTitle: "As Customer".getLocalizedString(), buttonBackgroundColor: AppColors.appGreenColor, textColor: .black)
        return button
    }()
    
    var isEmailValid:Bool = false
    var isPasswordValid:Bool = false
    let emailValidationRule = ValidationRulePattern(pattern: EmailValidationPattern.simple, error: MyValidationErrors.emailInvalid)
    let passwordValidationRule = PasswordValidationRule(error: MyValidationErrors.passwordInvalid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeNavBarBackButtonText()
        setupUIProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBar(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideNavBar(false, animated: animated)
    }
    
    func setupUIProperties(){
        let placeHolderAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        tfEmail.translatesAutoresizingMaskIntoConstraints = false
        tfEmail.delegate = self
        tfEmail.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        tfEmail.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        let tfEmailPlaceHolderText = NSAttributedString(string: "Email".getLocalizedString(), attributes: placeHolderAttributes)
        tfEmail.attributedPlaceholder = tfEmailPlaceHolderText
        tfEmail.font = UIFont.boldSystemFont(ofSize: 18)
        tfEmail.textColor = UIColor.white
        
        tfPassword.translatesAutoresizingMaskIntoConstraints = false
        tfPassword.delegate = self
        tfPassword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        tfPassword.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        let tfPasswordPlaceHolderText = NSAttributedString(string: "Password".getLocalizedString(), attributes: placeHolderAttributes)
        tfPassword.attributedPlaceholder = tfPasswordPlaceHolderText
        tfPassword.font = UIFont.boldSystemFont(ofSize: 18)
        tfPassword.textColor = UIColor.white
        
        btnForgotPassword.setTitle("Forgot password?".getLocalizedString(), for: .normal)
        btnSignIn.setTitle("Sign In".getLocalizedString(), for: .normal)
        btnSignIn.translatesAutoresizingMaskIntoConstraints = false
        btnSignIn.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        
        btnSignUp.setTitle("Sign Up".getLocalizedString(), for: .normal)
        btnSignUp.translatesAutoresizingMaskIntoConstraints = false
        btnSignUp.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        
        lblPasswordValidationInfo.text = ""
        
        setupSignUpOptionsView()
    }
    
    private func setupSignUpOptionsView(){
        signUpOptionsBackgroundView = SignUpOptionsBackgroundView()
        signUpOptionsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        signUpOptionsBackgroundView.backgroundColor = .clear//AppColors.appOrangeColor
        view.addSubview(signUpOptionsBackgroundView)
        signUpOptionsBackgroundView.anchor(top: btnSignUp.bottomAnchor, leading: tfEmail.leadingAnchor, trailing: tfEmail.trailingAnchor, bottom: nil, centerX: nil, centerY: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .zero)
        signUpOptionsBackgroundView.heightAnchor.constraint(lessThanOrEqualToConstant: 150).isActive = true
        btnSignUpAsCustomer.addTarget(self, action: #selector(signUpAsCustomerTapped), for: .touchUpInside)
        btnSignUpAsChef.addTarget(self, action: #selector(signUpAsChefTapped), for: .touchUpInside)
        let signUpOptionsHSV = SignUpOptionsHSV()
        signUpOptionsHSV.setSignUpOptions(items: [btnSignUpAsCustomer,btnSignUpAsChef])
        signUpOptionsHSV.spacing = 25
        signUpOptionsBackgroundView.addSubview(signUpOptionsHSV)
        signUpOptionsHSV.anchor(top: signUpOptionsBackgroundView.topAnchor, leading: signUpOptionsBackgroundView.leadingAnchor, trailing: signUpOptionsBackgroundView.trailingAnchor, bottom: signUpOptionsBackgroundView.bottomAnchor, padding: .init(top: 25, left: 10, bottom: 10, right: 10), size: .zero)
        signUpOptionsBackgroundView.isHidden = true
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
    
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot Password".getLocalizedString(), message: "Enter your email".getLocalizedString(), preferredStyle: .alert)
        forgotPasswordAlert.addTextField(configurationHandler: { [weak self] (tfEmail:UITextField) in
            tfEmail.placeholder = "Email".getLocalizedString()
            tfEmail.textColor = UIColor.black
            tfEmail.delegate = self
        })
        let resetAction = UIAlertAction(title: "Reset".getLocalizedString(), style: .destructive) { [weak self] (action) in
            guard let emailForResetPassword = forgotPasswordAlert.textFields![0].text else{
                 AlertService.showAlert(in: self, message: "Email not entered".getLocalizedString(), title: "", style: .alert)
                return
            }
            self?.sendPasswordResetEmail(to: emailForResetPassword)
        }
        let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        forgotPasswordAlert.addAction(closeAction)
        forgotPasswordAlert.addAction(resetAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(forgotPasswordAlert, animated: true, completion: nil)
        }
    }
    
    private func sendPasswordResetEmail(to email:String){
        let isEmailValid = email.validate(rule: emailValidationRule).isValid
        if isEmailValid{
            if NetworkManager.isConnectedNetwork() {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        // TODO: Error handling
                        AlertService.showAlert(in: self, message: error.localizedDescription, title: "", style: .alert)
                    }else{
                        AlertService.showAlert(in: self, message: "Şifre sıfırlama maili \(email) adresine gönderildi. Mailinizdeki adımları takip edebilirsiniz".getLocalizedString(), title: "", style: .alert)
                    }
                }
            }else{
                AlertService.showNoInternetConnectionErrorAlert(in: self, style: .actionSheet, blockUI: false)
            }
        }else{
            AlertService.showAlert(in: self, message: "Geçersiz mail adresi".getLocalizedString(), title: "", style: .alert)
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if isEmailValid && isPasswordValid {
            if NetworkManager.isConnectedNetwork() {
                signIn()
            } else{
                AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
            }
        }else{
            AlertService.showAlert(in: self, message: "Geçersiz mail veya parola !", title: "", style: .alert)
        }
    }
    
    
    private func signIn(){
        let email = tfEmail.text!
        let password = tfPassword.text!
        showActivityIndicatorView(isUserInteractionEnabled: false)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let authResult = authResult {
                if authResult.user.isEmailVerified {
                    Database.database().reference().child("users").child(authResult.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String:AnyObject], let accountInfoDictionary = dictionary["accountInfo"] as? [String:AnyObject]{
                            let accountInfo = AccountInfo(dictionary: accountInfoDictionary)
                            if let accountStatus = accountInfo.status, let accountType = accountInfo.accountType {
                                switch accountStatus {
                                case .enabled:
                                    self?.createUserSession(userId: authResult.user.uid, accountType: accountType)
                                    return
                                case .disabled:
                                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                                    AlertService.showAlert(in: self, message: "Hesabınız engellenmiş. Lütfen geliştirici ile iletişime geçiniz".getLocalizedString(), style: .alert)
                                    return
                                case .pendingApproval:
                                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                                    AlertService.showAlert(in: self, message: "Hesabınıza giriş yapabilmek için admin onayı bekleniyor. Hesabınız onaylandıktan sonra giriş yapabilirsiiniz".getLocalizedString(), style: .alert)
                                    return
                                }
                            }
                        }else{
                            self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                            AlertService.showAlert(in: self, message: "snapshot null geldi".getLocalizedString(), style: .alert)
                        }
                    })
                }else{
                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    let notVerifiedEmailAlert = UIAlertController(title: "NotVerifiedEmailAlertTitle".getLocalizedString(), message: "NotVerifiedEmailAlertMessage".getLocalizedString(), preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
                    let sendEmailVerificationAction = UIAlertAction(title: "Send Email Verification".getLocalizedString(), style: .default, handler: { (action) in
                        authResult.user.sendEmailVerification(completion: { (error) in
                            if let error = error {
                                AlertService.showAlert(in: self, message: error.localizedDescription, title: "Can Not Send Verification Email".getLocalizedString())
                            }else{
                                AlertService.showAlert(in: self, message: "Verification Email sent", title: "Succeed".getLocalizedString())
                            }
                        })
                    })
                    notVerifiedEmailAlert.addAction(closeAction)
                    notVerifiedEmailAlert.addAction(sendEmailVerificationAction)
                    DispatchQueue.main.async {
                        self?.present(notVerifiedEmailAlert, animated: true, completion: nil)
                    }
                }
            }else{
                self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                DispatchQueue.main.async {
                    AlertService.showAlert(in: self, message: error!.localizedDescription, title: "Error".getLocalizedString(), style: .alert)
                }
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
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
    
    @objc func signUpAsCustomerTapped(){
        self.signUpOptionsBackgroundView.isHidden = true
        let customerSignUpVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "CustomerSignUpVC") as! CustomerSignUpVC
        navigationController?.pushViewController(customerSignUpVC, animated: true)
    }
    
    @objc func signUpAsChefTapped(){
        self.signUpOptionsBackgroundView.isHidden = true
        let chefSignUpVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "ChefSignUpVC") as! ChefSignUpVC
        navigationController?.pushViewController(chefSignUpVC, animated: true)
    }
}

// HANDLE SIGN IN
extension LoginVC{
    
    private func createUserSession(userId:String, accountType:AccountType){
        let sessionsDbRef = Database.database().reference().child("sessions").child(userId)
        guard let sessionKey = sessionsDbRef.childByAutoId().key else{
            // TODO: Error handling
            self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            DispatchQueue.main.async {
                AlertService.showAlert(in: self, message: "Giriş yapılamadı tekrar deneyiniz", title: "", style: .alert)
            }
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
            "sessionStatus": SessionStatus.active.rawValue,
            "deviceAndAppInfo": deviceAndAppInfo
            ] as [String: AnyObject]
        
        sessionsDbRef.child(sessionKey).setValue(values, withCompletionBlock: { [weak self] (error, databaseRef) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    AlertService.showAlert(in: self, message: error.localizedDescription, title: "Error".getLocalizedString(), style: .alert)
                }
            }else{
                self?.registerFCMNotificationTokenToUserAccount(by: accountType, userId: userId)
                UserDefaults.standard.set(sessionKey, forKey: UserDefaultsKeys.userSessionId)
                DispatchQueue.main.async {
                    self?.hideActivityIndicatorView(isUserInteractionEnabled: true)
                    AppDelegate.shared.rootViewController.switchToMainScreen(by: accountType)
                }
            }
        })
    }
    
    func registerFCMNotificationTokenToUserAccount(by accountType: AccountType, userId: String){
        if let fcmToken = UserDefaults.standard.value(forKey: UserDefaultsKeys.firebaseNotificationToken) as? String{
            if NetworkManager.isConnectedNetwork() {
                var path = ""
                if accountType == .chef {
                    path = "chefs"
                }else if accountType == .customer {
                    path = "customers"
                }
                
                if path != "" {
                    Database.database().reference().child(path).child(userId).updateChildValues(["fcmToken":fcmToken])
                }
            }
        }
    }
}

// TEXT FIELD
extension LoginVC: UITextFieldDelegate{
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == tfEmail.tag {
            guard let email = tfEmail.text else {return}
            isEmailValid = email.validate(rule: emailValidationRule).isValid
            if isEmailValid {
                DispatchQueue.main.async { [weak self] in
                    self?.tfEmail.backgroundColor = AppColors.appGreenColor//.withAlphaComponent(0.5)
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
            if isPasswordValid{
                DispatchQueue.main.async { [weak self] in
                    self?.lblPasswordValidationInfo.text = ""
                    self?.tfPassword.backgroundColor = AppColors.appGreenColor//.withAlphaComponent(0.5)
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.lblPasswordValidationInfo.text = MyValidationErrors.passwordInvalid.message
                    self?.tfPassword.backgroundColor = AppColors.blockedRedColor.withAlphaComponent(0.5)
                }
            }
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case tfEmail.tag:
            return updatedText.count <= AppConstants.usernameAndEmailCharacterCountLimit
        case tfPassword.tag:
            return updatedText.count <= AppConstants.passwordMaxLength
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


