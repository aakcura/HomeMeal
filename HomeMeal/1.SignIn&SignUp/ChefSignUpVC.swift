//
//  ChefSignUpVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class ChefSignUpVC: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileInfoStack: UIStackView!
    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var biographyStack: UIStackView!
    @IBOutlet weak var resumeStack: UIStackView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameAndMailStack: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordStackTitleLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var biographyStackTitleLabel: UILabel!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var resumeLabel: UILabel!
    @IBOutlet weak var uploadResumeButton: UIButton!
    @IBOutlet weak var pickKitchenLocationButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBarTitle("Sign Up As Chef".getLocalizedString())
    }
    
    @IBAction func uploadResumeButtonClicked(_ sender: Any) {
    }
    
    @IBAction func pickKitchenLocationButtonClicked(_ sender: Any) {
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
    }
    
    
    
    
    
}
