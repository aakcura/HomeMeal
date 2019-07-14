//
//  ErrorTableViewCell.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

/*
import UIKit

class ErrorTableViewCell: UITableViewCell {

    var error: MyError!{
        didSet{
            if let errorImage = error.errorImage {
                self.errorImageViewHeightAnchorConstraint.isActive = false
                self.errorImageViewHeightAnchorConstraint.constant = 30
                self.errorImageViewHeightAnchorConstraint.isActive = true
                self.errorImageView.image = errorImage
            }else{
                self.errorImageViewHeightAnchorConstraint.isActive = false
                self.errorImageViewHeightAnchorConstraint.constant = 0
                self.errorImageViewHeightAnchorConstraint.isActive = true
                self.errorImageView.image = nil
            }
            if let errorMessage = error.errorMessage{
                self.errorMessageLabel.text = errorMessage
            }else{
                self.errorMessageLabel.text = ""
            }
        }
    }
    
    let errorImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let errorMessageLabel : UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    var errorImageViewHeightAnchorConstraint : NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(errorImageView)
        addSubview(errorMessageLabel)
        setupErrorTableViewCellLayout()
    }
    
    private func setupErrorTableViewCellLayout(){
        errorImageView.anchor(top: topAnchor, leading: nil, trailing: nil, bottom: nil, centerX: centerXAnchor, centerY: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 30, height: 0))
        self.errorImageViewHeightAnchorConstraint = errorImageView.heightAnchor.constraint(equalToConstant: 0)
        errorMessageLabel.anchor(top: errorImageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: nil, centerX: nil, centerY: nil, padding: .init(top: 10, left: 20, bottom: 0, right: 20), size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
*/
