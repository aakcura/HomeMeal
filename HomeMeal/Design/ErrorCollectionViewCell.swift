//
//  ErrorCollectionViewCell.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

/*
import UIKit

class ErrorCollectionViewCell: UICollectionViewCell {
    var error: MyError!{
        didSet{
            if let errorImage = error.errorImage {
                self.errorImageViewHeightAnchorConstraint.isActive = false
                self.errorImageViewHeightAnchorConstraint.constant = 25
                self.errorImageViewHeightAnchorConstraint.isActive = true
                self.errorImageView.image = errorImage
            }else{
                self.errorImageViewHeightAnchorConstraint.isActive = false
                self.errorImageViewHeightAnchorConstraint.constant = 0
                self.errorImageViewHeightAnchorConstraint.isActive = true
                self.errorImageView.image = nil
            }
            if let errorMessage = error.errorMessage{
                self.errorMessageText.text = errorMessage
            }else{
                self.errorMessageText.text = ""
            }
        }
    }
    
    let errorImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let errorMessageText : UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.textAlignment = .center
        return textView
    }()
    
    var errorImageViewHeightAnchorConstraint : NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(errorImageView)
        addSubview(errorMessageText)
        setupErrorCollectionViewCellLayout()
    }
    
    private func setupErrorCollectionViewCellLayout(){
        errorImageView.anchor(top: topAnchor, leading: nil, trailing: nil, bottom: nil, centerX: centerXAnchor, centerY: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 25, height: 0))
        self.errorImageViewHeightAnchorConstraint = errorImageView.heightAnchor.constraint(equalToConstant: 0)
        errorMessageText.anchor(top: errorImageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, centerX: nil, centerY: nil, padding: .init(top: 10, left: 20, bottom: 0, right: 20), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
*/
