//
//  FeedVC.swift
//  elisca
//
//  Created by Bilal Aydın on 3.02.2025.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var imageArray = [String]()
    var placeNameArray = [String]()
    var commentArray = [String]()
    var likeArray = [Int]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var userEmailArray = [String]()
    var documentIDArray = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FeedCell
        cell.commentLbl.text = commentArray[indexPath.row]
        cell.placeNameLbl.text = placeNameArray[indexPath.row]
        cell.userNameLbl.text = userEmailArray[indexPath.row]
        cell.likeLbl.text = String(likeArray[indexPath.row])
        cell.postImageView.sd_setImage(with: URL(string: imageArray[indexPath.row]))
        cell.documentIDlabel.text = documentIDArray[indexPath.row]
        return cell
    }
    
    func fetchData() {
        
        let db = Firestore.firestore()
        
        db.collection("Posts").order(by: "data", descending: true).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            }else {
               if snapshot?.isEmpty == false {
                    
                    self.placeNameArray.removeAll(keepingCapacity: false)
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.latitudeArray.removeAll(keepingCapacity: false)
                    self.longitudeArray.removeAll(keepingCapacity: false)
                    self.commentArray.removeAll(keepingCapacity: false)
                    self.likeArray.removeAll(keepingCapacity: false)
                    self.imageArray.removeAll(keepingCapacity: false)
                    self.documentIDArray.removeAll(keepingCapacity: false)
                   
                    
                    for post in snapshot!.documents {
                        
                        let documentID = post.documentID
                        self.documentIDArray.append(documentID)
                        print(documentID)
                        
                        if let imageUrl = post.get("imageUrl") as? String {
                            self.imageArray.append(imageUrl)
                        }
                        if let comment = post.get("comment") as? String {
                            self.commentArray.append(comment)
                        }
                        if let latitude = post.get("latitude") as? Double {
                            self.latitudeArray.append(latitude)
                        }
                        if let longitude = post.get("longitude") as? Double {
                            self.longitudeArray.append(longitude)
                        }
                        if let placeName = post.get("placeName") as? String {
                            self.placeNameArray.append(placeName)
                        }
                        if let userEmail = post.get("userEmail") as? String {
                            self.userEmailArray.append(userEmail)
                        }
                        if let likeCount = post.get("like") as? Int {
                            self.likeArray.append(likeCount)
                        }
                        
                    }
                    self.tableView.reloadData()
                
              }
            }
        }
        
        
    }
    
    
    
    

       func setupUI() {
        // Arka plan gradient ekleme
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
