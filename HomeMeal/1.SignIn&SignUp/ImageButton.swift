//
//  ImageButton.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Foundation

class ImageButton: UIButton {
    
    let buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let buttonTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)//UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.showsTouchWhenHighlighted = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonImageView)
        self.addSubview(buttonTitleLabel)
        self.setupLayoutProperties()
    }
    
    private func setupLayoutProperties(){
        buttonTitleLabel.anchor(top: nil, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, padding: .init(top: 0, left: 10, bottom: 5, right: 10), size: .init(width: 0, height: 20))
        buttonImageView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: buttonTitleLabel.topAnchor, padding: .init(top: 5, left: 5, bottom: 5, right: 5), size: .zero)
        buttonImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageButtonProperties(buttonImage: UIImage, buttonTitle: String, buttonBackgroundColor: UIColor = .clear, textColor: UIColor = .white){
        buttonImageView.image = buttonImage
        buttonTitleLabel.text = buttonTitle
        self.tintColor = .white
        buttonTitleLabel.textColor = textColor
        self.backgroundColor = buttonBackgroundColor
    }
    
}
