//
//  IngredientsTableViewCell.swift
//  HomeMeal
//
//  Created by Batuhan Abay on 11.08.2019.
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
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
        nameLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: seperatorLine.topAnchor)
        nameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
        seperatorLine.anchor(top: nameLabel.topAnchor, leading: nameLabel.trailingAnchor, trailing: nil, bottom: nameLabel.bottomAnchor, padding: .zero, size: .init(width: 2, height: 0))
        brandLabel.anchor(top: nameLabel.topAnchor, leading: seperatorLine.trailingAnchor, trailing: trailingAnchor, bottom: nameLabel.bottomAnchor, padding: .zero, size: .zero)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
