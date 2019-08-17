//
//  MealListTableViewCell.swift
//  HomeMeal
//
//  Created by Batuhan Abay on 16.08.2019.
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Cosmos

class MealListTableViewCell: UITableViewCell {

    var meal : Meal!{
        didSet{
            configureCell()
        }
    }
    
    let rootView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let profileSectionView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let lblChefName: UILabel = {
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
    
    let lblPrice: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center//.left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let verticalSeperatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let lblPreparationTime: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center//.right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let lblStartTime: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let lblEndTime: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none //satıra tıklandığında background rengini verir
        addSubview(rootView)
        rootView.addSubview(profileSectionView)
        profileSectionView.addSubview(lblChefName)
        profileSectionView.addSubview(ratingView)
        rootView.addSubview(mealDetailsSectionView)
        mealDetailsSectionView.addSubview(lblMealName)
        mealDetailsSectionView.addSubview(lblPrice)
        mealDetailsSectionView.addSubview(verticalSeperatorLine)
        mealDetailsSectionView.addSubview(lblPreparationTime)
        rootView.addSubview(lblStartTime)
        rootView.addSubview(lblEndTime)
        setupCellLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellLayout(){
        
        rootView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, padding: .init(top: 15, left: 15, bottom: 15, right: 15), size: .zero)
        rootView.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        rootView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        profileSectionView.anchor(top: rootView.topAnchor, leading: rootView.leadingAnchor, trailing: rootView.trailingAnchor, bottom: nil, padding: .init(top: 10, left: 15, bottom: 0, right: 15), size: .init(width: 0, height: 0))
        //profileSectionView.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        //profileSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        let profileSectionLeadingAnchor = profileSectionView.leadingAnchor
        let profileSectionTrailingAnchor = profileSectionView.trailingAnchor
        
        lblChefName.anchor(top: profileSectionView.topAnchor, leading: profileSectionLeadingAnchor, trailing: profileSectionTrailingAnchor, bottom: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 30))
        ratingView.anchor(top: lblChefName.bottomAnchor, leading: nil, trailing: nil, bottom: profileSectionView.bottomAnchor, centerX: profileSectionView.centerXAnchor, centerY: nil, padding: .init(top: 5, left: 0, bottom: 5, right: 0), size: .init(width: 0, height: 25))
        
        
        mealDetailsSectionView.anchor(top: profileSectionView.bottomAnchor, leading: profileSectionLeadingAnchor, trailing: profileSectionTrailingAnchor, bottom: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
        lblMealName.anchor(top: mealDetailsSectionView.topAnchor, leading: mealDetailsSectionView.leadingAnchor, trailing: mealDetailsSectionView.trailingAnchor, bottom: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 10), size: .init(width: 0, height: 30))
        verticalSeperatorLine.anchor(top: lblMealName.bottomAnchor, leading: nil, trailing: nil, bottom: mealDetailsSectionView.bottomAnchor, centerX: mealDetailsSectionView.centerXAnchor, centerY: nil, padding: .init(top: 0, left: 0, bottom: 5, right: 0), size: .init(width: 1, height: 26))
        lblPrice.anchor(top: nil, leading: mealDetailsSectionView.leadingAnchor, trailing: verticalSeperatorLine.leadingAnchor, bottom: nil, centerX: nil, centerY: verticalSeperatorLine.centerYAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 5), size: .init(width: 0, height: 30))
        lblPreparationTime.anchor(top: nil, leading: verticalSeperatorLine.trailingAnchor, trailing: mealDetailsSectionView.trailingAnchor, bottom: nil, centerX: nil, centerY: verticalSeperatorLine.centerYAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 10), size: .init(width: 0, height: 30))
        mealDetailsSectionView.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        mealDetailsSectionView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        lblStartTime.anchor(top: mealDetailsSectionView.bottomAnchor, leading: profileSectionLeadingAnchor, trailing: profileSectionTrailingAnchor, bottom: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 25))
        lblEndTime.anchor(top: lblStartTime.bottomAnchor, leading: profileSectionLeadingAnchor, trailing: profileSectionTrailingAnchor, bottom: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 25))
    }
    
    func configureCell(){
        lblChefName.text = meal.chefName
        
        if let chef = meal.chef {
            ratingView.rating = chef.rating
        }
        
        lblMealName.text = meal.mealName
        let priceText = "Price".getLocalizedString() + " \(meal.price) " + meal.currencySymbol
        lblPrice.text = priceText
        let hourText = "hour".getLocalizedString()
        let minuteText = "min".getLocalizedString()
        let (hour,minute) = meal.detailedPreparationTime
        var preparationTimeString = ""
        if hour == 0 {
            preparationTimeString = " \(minute) " + minuteText
        }else{
            preparationTimeString = " \(hour) " + hourText + " \(minute) " + minuteText
        }
        let preparationTimeText = NSMutableAttributedString(string: preparationTimeString)
        let clockIcon = NSMutableAttributedString(string: AppIcons.faClockRegular)
        clockIcon.addCustomAttributes(fontType: .regularFontAwesome, fontSize: 17, color: .black, range: nil, underlineStyle: nil)
        clockIcon.append(preparationTimeText)
        lblPreparationTime.attributedText = clockIcon
        
        let startTimeText = "Start Time".getLocalizedString() + ": "
        let attributedStartTimeText = NSMutableAttributedString(string: startTimeText)
        attributedStartTimeText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        if let startDateAndTimeString = meal.detailedStartTime?.dateAndTimeFullString{
            let attributedStartDateAndTimeString = NSMutableAttributedString(string: startDateAndTimeString)
            attributedStartTimeText.append(attributedStartDateAndTimeString)
        }
        
        let endTimeText = "End Time".getLocalizedString() + ": "
        let attributedEndTimeText = NSMutableAttributedString(string: endTimeText)
        attributedEndTimeText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        if let endDateAndTimeString = meal.detailedEndTime?.dateAndTimeFullString{
            let attributedEndDateAndTimeString = NSMutableAttributedString(string: endDateAndTimeString)
            attributedEndTimeText.append(attributedEndDateAndTimeString)
        }
        
        lblStartTime.attributedText = attributedStartTimeText
        lblEndTime.attributedText = attributedEndTimeText
    }
    
}
