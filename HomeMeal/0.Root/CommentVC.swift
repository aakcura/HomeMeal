//
//  CommentVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

protocol CommentVCPresentationDelegate{
    ///Closes the comment popup.
    func closeCommentPopup()
}

protocol CommentVCDataTransferDelegate{
    /// Send newly added comment ıd
    func newCommentAddedWith(commentId:String)
}

class CommentVC: UIViewController {
    
    enum CommentStatus {
        case newComment
        case existingComment
    }
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnAddComment: UIButton!
    
    var commentId: String? {
        didSet{
            if let commentId = self.commentId {
                self.getComment(by: commentId) { (comment) in
                    if let comment = comment{
                      self.configureViewForExistingComment(comment)
                    }else{
                        // TODO: show error comment bulunmaadı
                    }
                }
            }else{
                self.configureViewForNewComment()
            }
        }
    }
    var order: Order? {
        didSet{
            if let order = self.order, let commentId = order.orderDetails.commentId{
                self.commentId = commentId
            }else{
                self.commentId = nil
            }
        }
    }
    
    var presentationDelegate: CommentVCPresentationDelegate?
    var dataTransferDelegate: CommentVCDataTransferDelegate?
    var rating: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        popupView.setCornerRadius(radiusValue: 10.0, makeRoundCorner: false)
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        ratingView.settings.fillMode = .precise
        tvComment.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
        btnAddComment.setTitle("Add Comment".getLocalizedString(), for: .normal)
        btnAddComment.setCornerRadius(radiusValue: 5.0, makeRoundCorner: false)
    }
    
    private func setupRatingView(for commentStatus:CommentStatus){
        if commentStatus == .newComment {
            ratingView.settings.updateOnTouch = true
            ratingView.didTouchCosmos = { rating in
                let roundedRating = round(rating * 10) / 10
                self.ratingView.text = "\(roundedRating)"
                self.rating  = roundedRating
            }
        }
        if commentStatus == .existingComment {
            ratingView.settings.updateOnTouch = false
        }
    }
    
    private func configureViewForNewComment(){
        setupRatingView(for: .newComment)
    }
    
    private func configureViewForExistingComment(_ comment: Comment){
        setupRatingView(for: .existingComment)
        self.ratingView.rating = comment.rating
        self.ratingView.text = "\(comment.rating)"
        self.tvComment.text = comment.commentText ?? "Yorum bulunmamaktadır".getLocalizedString()
        self.tvComment.isEditable = false
        self.btnAddComment.isEnabled = false
        self.btnAddComment.isHidden = true
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if self.presentationDelegate != nil {
            self.presentationDelegate?.closeCommentPopup()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addCommentTapped(_ sender: Any) {
        if NetworkManager.isConnectedNetwork(){
            guard let order = self.order else {
                return
            }
            
            let commentsDbRef = Database.database().reference().child("comments")
            guard let newCommentId = commentsDbRef.childByAutoId().key else{
                DispatchQueue.main.async {
                    AlertService.showAlert(in: self, message: "Comment Oluşturulamadı".getLocalizedString(), title: "", style: .alert)
                }
                return
            }
            
            var dictionary = [
                "chefId": order.orderDetails.chefId,
                "chefName": order.orderDetails.chefName,
                "commentId": newCommentId,
                "commentTime": Date().timeIntervalSince1970,
                "customerId": order.orderDetails.customerId,
                "customerName": order.orderDetails.customerName,
                "orderId": order.orderDetails.orderId,
                "rating": self.rating ?? 0.0
                ] as [String:AnyObject]
            
            if !tvComment.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                dictionary["commentText"] = tvComment.text as AnyObject
            }
            
            self.addComment(newCommentId: newCommentId, values: dictionary) { (error) in
                if let error = error {
                    AlertService.showAlert(in: self, message: error.localizedDescription)
                }else{
                    let alert = UIAlertController(title: nil, message: "Yorumunuz eklendi".getLocalizedString(), preferredStyle: .alert)
                    let closeButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: { (action) in
                        self.dataTransferDelegate?.newCommentAddedWith(commentId: newCommentId)
                        self.closeTapped(true)
                    })
                    
                    alert.addAction(closeButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            AlertService.showNoInternetConnectionErrorAlert(in: self)
        }
    }

}

// FIREBASE OPERATIONS
extension CommentVC {
    
    private func addComment(newCommentId:String, values: [String:AnyObject], completion: @escaping (Error?) -> Void){
        let dbPath = "comments/\(newCommentId)"
        Database.database().reference().child(dbPath).setValue(values) { (error, dbRef) in
            completion(error)
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
