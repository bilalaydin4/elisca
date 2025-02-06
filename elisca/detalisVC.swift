//
//  detalisVC.swift
//  elisca
//
//  Created by Bilal Aydın on 5.02.2025.
//

import UIKit
import MapKit
import FirebaseFirestore
import SDWebImage

class detalisVC: UIViewController, MKMapViewDelegate {
    
    
    
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var imageVieww: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var chosenDocument = ""
    var annotationTitle : String?
    var annotationSubtitle : String?
    var annotationLatitude : Double?
    var annotationLongitude : Double?

    override func viewDidLoad() {
        super.viewDidLoad()

        print(chosenDocument)
        
        //setupUI()
        mapView.delegate = self
        
        
        if chosenDocument != "" {
            
            var choseenDocuments = [chosenDocument]
            
            let db = Firestore.firestore()
            
            db.collection("Posts")
                .whereField(FieldPath.documentID(), in: choseenDocuments)
                .addSnapshotListener { snapshot, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "Error")
                    } else {
                        if snapshot!.isEmpty == false {
                            for document in snapshot!.documents {
                          
                                if let comment = document.get("comment") as? String {
                                    self.commentLbl.text = "\(comment)"
                                    self.annotationSubtitle = comment
                                }
                                if let imageUrlString = document.get("imageUrl") as? String {
                                    let imageUrl = URL(string: imageUrlString)!
                                    self.imageVieww.sd_setImage(with: imageUrl)
                                }
                                if let placeName = document.get("placeName") as? String {
                                    self.placeName.text = "\(placeName)"
                                    self.annotationTitle = placeName
                                }
                                if let like = document.get("like") as? Int {
                                    self.likeCount.text = "\(like)"
                                }
                                if let latitude = document.get("latitude") as? Double {
                                    if let longitude = document.get("longitude") as? Double {
                                        
                                        let annotation = MKPointAnnotation()
                                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                        annotation.coordinate = coordinate
                                        self.mapView.addAnnotation(annotation)
                                        
                                        let span = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        self.mapView.setRegion(region, animated: true)
                                    }
                                }
                                
                            }
                        } else {
                            print("No documents found.")
                        }
                    }
                }
            
        }
    }
    
    private func setupUI() {
        // Görsel öğeleri özelleştirme
        imageVieww.layer.cornerRadius = 10
        imageVieww.clipsToBounds = true
        imageVieww.contentMode = .scaleAspectFill
        
        placeName.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        placeName.textColor = .darkText
        
        commentLbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        commentLbl.textColor = .gray
        commentLbl.numberOfLines = 0 // Çok satırlı metin desteği
        
        likeCount.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        likeCount.textColor = .systemPink

    }
    

}
