//
//  ChefReviewsTableViewCell.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Cosmos

class ChefReviewsTableViewCell: UITableViewCell {
    
    var comment : Comment!{
        didSet{
            configureCell()
        }
    }
    
    let rootView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let lblCustomerName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let mealDetailsSectionView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let lblMealName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let ratingView: CosmosView = {
        let cosmos = CosmosView()
        cosmos.settings.updateOnTouch = false
        cosmos.settings.fillMode = .precise
        cosmos.settings.starSize = 25.0
        cosmos.settings.totalStars = 5
        cosmos.settings.filledColor = AppColors.appOrangeColor
        cosmos.rating = 0.0
        return cosmos
    }()
    
    
    let tvComment: UITextView = {
        let tv = UITextView()
        tv.textColor = .black
        tv.font = UIFont.boldSystemFont(ofSize: 14)
        tv.isEditable = false
        tv.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        return tv
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none //satıra tıklandığında background rengini verir
        addSubview(rootView)
        rootView.addSubview(lblCustomerName)
        rootView.addSubview(mealDetailsSectionView)
        mealDetailsSectionView.addSubview(lblMealName)
        mealDetailsSectionView.addSubview(ratingView)
        rootView.addSubview(tvComment)
        setupCellLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellLayout(){
        
        rootView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, padding: .init(top: 10, left: 10, bottom: 10, right: 10), size: .zero)
        rootView.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        rootView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
  
        lblCustomerName.anchor(top: rootView.topAnchor, leading: rootView.leadingAnchor, trailing: rootView.trailingAnchor, bottom: nil, padding: .init(top: 15, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 30))
        lblCustomerName.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        lblCustomerName.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        mealDetailsSectionView.anchor(top: lblCustomerName.bottomAnchor, leading: lblCustomerName.leadingAnchor, trailing: lblCustomerName.trailingAnchor, bottom: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        lblMealName.anchor(top: mealDetailsSectionView.topAnchor, leading: mealDetailsSectionView.leadingAnchor, trailing: mealDetailsSectionView.trailingAnchor, bottom: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 25))
        ratingView.anchor(top: lblMealName.bottomAnchor, leading: nil, trailing: nil, bottom: mealDetailsSectionView.bottomAnchor, centerX: mealDetailsSectionView.centerXAnchor, centerY: nil, padding: .init(top: 5, left: 0, bottom: 5, right: 0), size: .init(width: 0, height: 25))
        //mealDetailsSectionView.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        //mealDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        tvComment.anchor(top: mealDetailsSectionView.bottomAnchor, leading: mealDetailsSectionView.leadingAnchor, trailing: mealDetailsSectionView.trailingAnchor, bottom: nil, padding: .init(top: 5, left: 0, bottom: 5, right: 0), size: .init(width: 0, height: 75))
        tvComment.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
    }
    
    func configureCell(){
        lblCustomerName.text = comment.customerName
        lblMealName.text = comment.mealName
        ratingView.rating = comment.rating
        tvComment.text = comment.commentText
    }
    
}



