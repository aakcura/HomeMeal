//
//  RootVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    private var currentVC: UIViewController
    var deepLink: DeepLinkType? {
        didSet{
            handleDeepLink()
        }
    }
    
    init() {
        self.currentVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SplashVC")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(currentVC)
        currentVC.view.frame = view.bounds
        view.addSubview(currentVC.view)
        currentVC.didMove(toParent: self)
    }
    
    private func handleDeepLink(){
        // make sure we are on the correct screen
        if let mainNavigationController = currentVC as? MainNavigationController, let deepLink = deepLink {
            switch deepLink {
            case .activity:
                mainNavigationController.popToRootViewController(animated: false) // we want to dismiss all the view controllers, that may be pushed already
                (mainNavigationController.topViewController as? MainVC)?.showActivityScreen() // and push the activity view controller from the parent navigation controller
            default:
                // handle any other types of Deeplinks here
                break
            }
            
            self.deepLink = nil
        }
    }
    
    func showLoginScreen() {
        let loginViewController = AppDelegate.storyboard.instantiateViewController(withIdentifier: "LoginVC")
        let new = UINavigationController(rootViewController: loginViewController)
        addChild(new)
        new.view.frame = view.bounds
        view.addSubview(new.view)
        new.didMove(toParent: self)
        currentVC.willMove(toParent: nil)
        currentVC.view.removeFromSuperview()
        currentVC.removeFromParent()
        currentVC = new
    }
    
    func switchToMainScreen() {
        let mainViewController = MainVC()
        let mainScreen =  MainNavigationController(rootViewController: mainViewController) //UINavigationController(rootViewController: mainViewController)
        animateFadeTransition(to: mainScreen) { [weak self] in
            self?.handleDeepLink()
        }
    }
    
    
    func switchToLogout() {
        let loginViewController = AppDelegate.storyboard.instantiateViewController(withIdentifier: "LoginVC")
        let logoutScreen = UINavigationController(rootViewController: loginViewController)
        animateDismissTransition(to: logoutScreen)
    }
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        currentVC.willMove(toParent: nil)
        addChild(new)
        
        transition(from: currentVC, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            self.currentVC.removeFromParent()
            new.didMove(toParent: self)
            self.currentVC = new
            completion?()
        }
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        let initialFrame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        currentVC.willMove(toParent: nil)
        addChild(new)
        transition(from: currentVC, to: new, duration: 0.3, options: [], animations: {
            new.view.frame = self.view.bounds
        }) { completed in
            self.currentVC.removeFromParent()
            new.didMove(toParent: self)
            self.currentVC = new
            completion?()
        }
    }
    
}
