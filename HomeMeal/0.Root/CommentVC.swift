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

class CommentVC: UIViewController {
    
    enum CommentStatus {
        case newComment
        case existingComment
    }
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var popupView: UIView!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var lblCommentTitle: UILabel!
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
    
    var delegate: CommentVCPresentationDelegate?
    var rating: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        //popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.setCornerRadius(radiusValue: 10.0, makeRoundCorner: false)
        
        //btnClose.translatesAutoresizingMaskIntoConstraints = false
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        ratingView.settings.fillMode = .precise
        lblCommentTitle.text = "Comment".getLocalizedString()
        btnAddComment.setTitle("Add Comment".getLocalizedString(), for: .normal)
    }
    
    private func setupRatingView(for commentStatus:CommentStatus){
        if commentStatus == .newComment {
            ratingView.settings.updateOnTouch = true
            ratingView.didTouchCosmos = { rating in
                self.ratingView.text = "\(rating)"
                self.rating  = rating
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
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        if self.delegate != nil {
            self.delegate?.closeCommentPopup()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func addCommentTapped(_ sender: Any) {
    }

}

// FIREBASE OPERATIONS
extension CommentVC {
    
    private func addComment(values: [String:AnyObject], completion: @escaping (Error?) -> Void){
        // TODO: ADD comment to database
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
