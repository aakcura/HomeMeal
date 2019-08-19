//
//  ChefReviewsVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

protocol ChefReviewsVCPresentationDelegate{
    ///Closes the ChefReviews popup.
    func closeChefReviewsPopup()
}

class ChefReviewsVC: BaseVC {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableReviews: UITableView!
    @IBOutlet weak var btnClose: UIButton!

    var presentationDelegate: ChefReviewsVCPresentationDelegate?
    
    var chefId: String?
    var comments = [Comment]()
    var timer: Timer?
    let reviewsTableCellId = "reviewsTableCellId"
    let noCommentsErrorMessage = "No Comments Error Message".getLocalizedString()
    let reviewsTableCellHeight: CGFloat = {
        return CGFloat.init(230.0)
    }()
    let emptyReviewsTableCellHeight: CGFloat = {
        return CGFloat.init(50.0)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
        if let chefId = self.chefId {
            observeChefComments(with: chefId)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addNetworkStatusListener()
    }
    
    private func setupUIProperties(){
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        popupView.setCornerRadius(radiusValue: 10.0, makeRoundCorner: false)
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        lblTitle.text = "Reviews".getLocalizedString()
        setupTableView()
        addActivityIndicatorToView()
    }
    
    
    @IBAction func closeTapped(_ sender: Any) {
        if self.presentationDelegate != nil {
            self.presentationDelegate?.closeChefReviewsPopup()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupTableView(){
        tableReviews.register(ChefReviewsTableViewCell.self, forCellReuseIdentifier: reviewsTableCellId)
        tableReviews.backgroundColor = .clear
        tableReviews.separatorStyle = .none
        tableReviews.dataSource = self
        tableReviews.delegate = self
    }

    private func addCommentToCommentsArray(_ comment:Comment){
        comments.append(comment)
        attemptReloadOfTableView()
    }
}

// TABLE VIEW
extension ChefReviewsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currentCell = tableView.cellForRow(at: indexPath) as? ChefReviewsTableViewCell{
            if let selectedComment = currentCell.comment {
                // TODO: go comment detail
                print(selectedComment.customerName)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if comments.isEmpty {
            return emptyReviewsTableCellHeight
        }else{
            return reviewsTableCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments.isEmpty {
            return 1
        }else{
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments.isEmpty {
            return getEmptyOrdersErrorCell(with: noCommentsErrorMessage)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reviewsTableCellId, for: indexPath) as! ChefReviewsTableViewCell
            cell.comment = comments[indexPath.row]
            return cell
        }
    }
    
    public func attemptReloadOfTableView() {
        if !activityIndicator.isAnimating{
            showActivityIndicatorView(isUserInteractionEnabled: false)
        }
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.sortComments()
        DispatchQueue.main.async(execute: {
            self.tableReviews.reloadData()
            if self.activityIndicator.isAnimating{
                self.hideActivityIndicatorView(isUserInteractionEnabled: true)
            }
        })
    }
    
    private func sortComments(){
        self.comments.sort { (comment2, comment1) -> Bool in
            return comment2.commentTime > comment1.commentTime
        }
    }
    
    private func getEmptyOrdersErrorCell(with message:String) -> UITableViewCell{
        let errorCell = UITableViewCell()
        errorCell.textLabel?.textAlignment = .center
        errorCell.textLabel?.text = message
        return errorCell
    }
}

// FIREBASE OPERATIONS
extension ChefReviewsVC {
    
    private func observeChefComments(with chefId:String){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("chefComments/\(chefId)/commentList").observe(.childAdded) { (snapshot) in
                let commentId = snapshot.key
                self.getComment(by: commentId, completion: { (comment) in
                    if let comment = comment {
                        self.addCommentToCommentsArray(comment)
                    }
                })
            }
        }else{
            AlertService.showNoInternetConnectionErrorAlert(in: self)
        }
    }
    
    private func getComment(by commentId:String, completion: @escaping (Comment?) -> Void){
        Database.database().reference().child("comments/\(commentId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let comment = Comment(dictionary: dictionary)
                completion(comment)
            }else{
                completion(nil)
            }
        })
    }
}

