//
//  ConnectionLostVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class ConnectionLostVC: UIViewController {
    
    let connectionLostLabel: UILabel = {
        let label = UILabel()
        label.text = "ConnectionLostMessage".getLocalizedString()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let connectionLostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcons.appIcon
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let networkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColors.appOrangeRedColor
        setupLayoutConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        networkManager.reachability.whenReachable = { reach in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupLayoutConstraints(){
        view.addSubview(connectionLostImageView)
        view.addSubview(connectionLostLabel)
        connectionLostLabel.anchor(centerToView: self.view, top: nil, leading: self.view.leadingAnchor, trailing: self.view.trailingAnchor, bottom: nil, padding: .init(top: 0, left: 20, bottom: 0, right: 20), size: .zero)
        connectionLostImageView.anchor(top: nil, leading: nil, trailing: nil, bottom: connectionLostLabel.topAnchor, centerX: self.view.centerXAnchor, centerY: nil, padding: .init(top: 0, left: 0, bottom: 20, right: 0), size: .init(width: 100, height: 100))
    }
    
}

