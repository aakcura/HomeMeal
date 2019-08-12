//
//  IngredientsTableViewCell.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .lightGray
        return label
    }()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .lightGray
        return label
    }()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubview(nameLabel)
        addSubview(brandLabel)
        addSubview(seperatorLine)
        self.setupLayoutFeatures()
    }
    
    private func setupLayoutFeatures(){
        seperatorLine.anchor(top: topAnchor, leading: nil, trailing: nil, bottom: bottomAnchor, centerX: centerXAnchor, centerY: nil, padding: .init(top: 2, left: 0, bottom: 2, right: 0), size: .init(width: 1, height: 0))
        nameLabel.anchor(top: seperatorLine.topAnchor, leading: leadingAnchor, trailing: seperatorLine.leadingAnchor, bottom: seperatorLine.bottomAnchor, padding: .zero, size: .zero)
        brandLabel.anchor(top: seperatorLine.topAnchor, leading: seperatorLine.trailingAnchor, trailing: trailingAnchor, bottom: seperatorLine.bottomAnchor, padding: .zero, size: .zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
