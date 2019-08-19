//
//  SocialMediaAccountButton.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Foundation

class SocialMediaAccountButton: UIButton {

    let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.font = FontAwesomeFonts.brands.withSize(35)
        label.textAlignment = .center
        return label
    }()
    
    var socialMediaAccount: SocialAccount?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonTitleLabel)
        self.setupLayoutProperties()
    }
    
    private func setupLayoutProperties(){
        buttonTitleLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSocialMediaAccount(_ socialMediaAccount: SocialAccount, buttonBackgroundColor: UIColor = .clear){
        self.socialMediaAccount = socialMediaAccount
        var buttonTitleText = ""
        var buttonTitleColor: UIColor = .black
        switch socialMediaAccount.accountType {
        case .linkedin:
            buttonTitleText = AppIcons.faLinkedinBrand
            buttonTitleColor = AppColors.linkedinColor
            break
        case .twitter:
            buttonTitleText = AppIcons.faTwitterBrand
            buttonTitleColor = AppColors.twitterColor
            break
        case .instagram:
            buttonTitleText = AppIcons.faInstagramBrand
            buttonTitleColor = AppColors.instagramColor
            break
        case .pinterest:
            buttonTitleText = AppIcons.faPinterestBrand
            buttonTitleColor = AppColors.pinterestColor
            break
        }
        self.buttonTitleLabel.textColor = buttonTitleColor
        self.buttonTitleLabel.text = buttonTitleText
        self.backgroundColor = buttonBackgroundColor
        self.addTarget(self, action: #selector(SocialMediaAccountButton.clicked), for: .touchUpInside)
    }
    
    @objc func clicked() {
        guard let url = self.socialMediaAccount?.url else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}


