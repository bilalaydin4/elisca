//
//  FeedCell.swift
//  elisca
//
//  Created by Bilal Aydın on 3.02.2025.
//

import UIKit
import SDWebImage // Resim yükleme için SDWebImage kütüphanesi
import FirebaseFirestore

class FeedCell: UITableViewCell {

    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var placeNameLbl: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var documentIDlabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }


    @IBAction func likeButtonTapped(_ sender: UIButton) {
        
        let db = Firestore.firestore()
        
        if let likeCount = Int(likeLbl.text!) {
            
            let newLike = ["like" : likeCount + 1] as [String: Any]
            
            db.collection("Posts").document(documentIDlabel.text!).setData(newLike, merge: true)
        }
            
        
        
        sender.isSelected.toggle()
        animateLikeButton(sender)
    }
    
    
    private func setupUI() {
        // Post ImageView stil ayarı
        postImageView.layer.cornerRadius = 2 // Köşeleri yuvarlak yapma
        postImageView.layer.masksToBounds = true
        postImageView.layer.borderWidth = 1
        postImageView.layer.borderColor = UIColor.systemGray4.cgColor
        postImageView.contentMode = .scaleAspectFill

        // Like butonu stil ayarı
        likeButton.tintColor = .systemRed
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)

        // Label stil ayarları
        userNameLbl.font = UIFont.boldSystemFont(ofSize: 16)
        userNameLbl.textColor = .label

        placeNameLbl.font = UIFont.systemFont(ofSize: 14)
        placeNameLbl.textColor = .secondaryLabel

        commentLbl.font = UIFont.systemFont(ofSize: 14)
        commentLbl.textColor = .label

        likeLbl.font = UIFont.systemFont(ofSize: 14)
        likeLbl.textColor = .label

        // Hücre arka planı
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }

    private func animateLikeButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                button.transform = CGAffineTransform.identity
            }
        }
    }
}
