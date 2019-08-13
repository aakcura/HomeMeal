//
//  ChefOrdersTableViewCell.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class ChefOrdersTableViewCell: UITableViewCell {
    
    var order : Order!{
        didSet{
            configureCell()
        }
    }
    
    let activeOrderBackgroundColor = UIColor.white
    let passiveOrderBackgroundColor = UIColor.white //UIColor.init(white: 0.9, alpha: 1)
    
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
    
    let lblMealName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let upSeperatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let priceAndPreparationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
    
    let bottomSeperatorLine : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let lblOrderStatus: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let lblOrderTime: UILabel = {
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
        rootView.addSubview(lblCustomerName)
        rootView.addSubview(lblMealName)
        rootView.addSubview(upSeperatorLine)
        rootView.addSubview(priceAndPreparationContainerView)
        priceAndPreparationContainerView.addSubview(lblPrice)
        priceAndPreparationContainerView.addSubview(verticalSeperatorLine)
        priceAndPreparationContainerView.addSubview(lblPreparationTime)
        rootView.addSubview(bottomSeperatorLine)
        rootView.addSubview(lblOrderStatus)
        rootView.addSubview(lblOrderTime)
        setupCellLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellLayout(){
        rootView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, padding: .init(top: 7, left: 5, bottom: 7, right: 5), size: .zero)
        rootView.setCornerRadius(radiusValue: 5, makeRoundCorner: false)
        rootView.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        let rootViewLeadingAnchor = rootView.leadingAnchor
        let rootViewTrailingAnchor = rootView.trailingAnchor
        let rootViewTopAnchor = rootView.topAnchor
        let rootViewBottomAnchor = rootView.bottomAnchor
        
        lblCustomerName.anchor(top: rootViewTopAnchor, leading: rootViewLeadingAnchor, trailing: rootViewTrailingAnchor, bottom: nil, padding: .init(top: 10, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 30))
        lblCustomerName.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        lblCustomerName.setBorder(borderWidth: 1, borderColor: AppColors.appBlackColor)
        
        lblMealName.anchor(top: lblCustomerName.bottomAnchor, leading: rootViewLeadingAnchor, trailing: rootViewTrailingAnchor, bottom: nil, padding: .init(top: 5, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 30))
        
        upSeperatorLine.anchor(top: lblMealName.bottomAnchor, leading: rootViewLeadingAnchor, trailing: rootViewTrailingAnchor, bottom: nil, padding: .init(top: 5, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 1))
        
        priceAndPreparationContainerView.anchor(top: upSeperatorLine.bottomAnchor, leading: rootViewLeadingAnchor, trailing: rootViewTrailingAnchor, bottom: nil, padding: .init(top: 2, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 30))
        verticalSeperatorLine.anchor(top: priceAndPreparationContainerView.topAnchor, leading: nil, trailing: nil, bottom: priceAndPreparationContainerView.bottomAnchor, centerX: priceAndPreparationContainerView.centerXAnchor, centerY: nil, padding: .init(top: 2, left: 0, bottom: 2, right: 0), size: .init(width: 1, height: 0))
        lblPrice.anchor(top: priceAndPreparationContainerView.topAnchor, leading: priceAndPreparationContainerView.leadingAnchor, trailing: verticalSeperatorLine.leadingAnchor, bottom: priceAndPreparationContainerView.bottomAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .zero)
        lblPreparationTime.anchor(top: priceAndPreparationContainerView.topAnchor, leading: verticalSeperatorLine.trailingAnchor, trailing: priceAndPreparationContainerView.trailingAnchor, bottom: priceAndPreparationContainerView.bottomAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .zero)
        bottomSeperatorLine.anchor(top: priceAndPreparationContainerView.bottomAnchor, leading: upSeperatorLine.leadingAnchor, trailing: upSeperatorLine.trailingAnchor, bottom: nil, padding: .init(top: 2, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 1))
        
        lblOrderStatus.anchor(top: bottomSeperatorLine.bottomAnchor, leading: rootViewLeadingAnchor, trailing: rootViewTrailingAnchor, bottom: nil, padding: .init(top: 5, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 25))
        lblOrderTime.anchor(top: lblOrderStatus.bottomAnchor, leading: rootViewLeadingAnchor, trailing: rootViewTrailingAnchor, bottom: nil, padding: .init(top: 5, left: 25, bottom: 0, right: 25), size: .init(width: 0, height: 25))
    }
    
    func configureCell(){
        rootView.backgroundColor = passiveOrderBackgroundColor
        
        lblCustomerName.text = order.orderDetails.customerName
        
        lblMealName.text = order.mealDetails.mealName
        
        let priceText = "Price".getLocalizedString() + " \(order.mealDetails.price) " + order.mealDetails.currencySymbol
        lblPrice.text = priceText
        let hourText = "hour".getLocalizedString()
        let minuteText = "min".getLocalizedString()
        let (hour,minute) = order.mealDetails.detailedPreparationTime
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
        
        self.setOrderStatusText()
        self.setOrderTimeText()
    }
    
    private func setOrderStatusText(){
        let orderStatus = order.orderDetails.orderStatus
        let currentOrderStatusText = "Current Order Status".getLocalizedString() + ": "
        let attributedCurrentOrderStatusText = NSMutableAttributedString(string: currentOrderStatusText)
        attributedCurrentOrderStatusText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        var orderStatusString = ""
        switch orderStatus {
        case .received:
            orderStatusString = OrderStatusText.received.text
            break
        case .canceled:
            orderStatusString = OrderStatusText.canceled.text
            break
        case .rejected:
            orderStatusString = OrderStatusText.rejected.text
            break
        case .preparing:
            orderStatusString = OrderStatusText.preparing.text
            break
        case .prepared:
            orderStatusString = OrderStatusText.prepared.text
            break
        }
        let orderStatusText = NSMutableAttributedString(string: orderStatusString)
        attributedCurrentOrderStatusText.append(orderStatusText)
        lblOrderStatus.attributedText = attributedCurrentOrderStatusText
    }
    
    private func setOrderTimeText(){
        let orderTimeText = "Order Time".getLocalizedString() + ": "
        let attributedOrderTimeText = NSMutableAttributedString(string: orderTimeText)
        attributedOrderTimeText.addCustomAttributes(fontType: .boldSystem, fontSize: 14, color: .black, range: nil, underlineStyle: nil)
        if let orderDateAndTimeString = order.orderDetails.detailedOrderTime?.dateAndTimeFullString{
            let attributedOrderDateAndTimeString = NSMutableAttributedString(string: orderDateAndTimeString)
            attributedOrderTimeText.append(attributedOrderDateAndTimeString)
        }
        
        self.lblOrderTime.attributedText = attributedOrderTimeText
    }
    
}
