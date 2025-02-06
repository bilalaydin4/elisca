//
//  UploadVC.swift
//  elisca
//
//  Created by Bilal Aydın on 3.02.2025.
//
import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UploadVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate,CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var comment: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var isLocationUpdated = false
    let annotaion = MKPointAnnotation()
    
    var myLatitude : Double?
    var myLongitude : Double?
    let currentUser = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if isLocationUpdated == false {
            let coordinate = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            myLatitude = locations[0].coordinate.latitude
            myLongitude = locations[0].coordinate.longitude
            let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            isLocationUpdated = true
            
            annotaion.coordinate = coordinate
            annotaion.title = "I writeing this location"
            mapView.addAnnotation(annotaion)
            
        }
    }


    @IBAction func uploadButtonClicked(_ sender: Any) {
        
        if placeName.text != "" && postImage.image != nil && comment.text != "" && currentUser != nil{
            
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let mediaFolder = storageRef.child("media")
            
            let uuid = UUID().uuidString
            
            if let imageData = postImage.image?.jpegData(compressionQuality: 0.3) {
                let imageRef = mediaFolder.child("\(uuid).jpg")
                
                imageRef.putData(imageData) { metadata, error in
                    if error != nil {
                        self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                    }else{
                        imageRef.downloadURL { url, error in
                            if error == nil {
                                if let imageUrl = url?.absoluteString {
                                    print(imageUrl)
                                    
                                    
                                    // DATABASE
                                    
                                    let db = Firestore.firestore()
                                    let dbRef : DocumentReference?
                                    
                                    if let myLatitude = self.myLatitude, let myLongitude = self.myLongitude {
                                       
                                        if let currentUserEmail = self.currentUser!.email {
                                            
                                            let postData : [String:Any] = [
                                                
                                                "latitude": myLatitude,
                                                "longitude" : myLongitude,
                                                "imageUrl" : imageUrl,
                                                "comment" : self.comment.text!,
                                                "placeName" : self.placeName.text!,
                                                "userEmail" : currentUserEmail,
                                                "like" : 0,
                                                "data" : FieldValue.serverTimestamp()
                                            ]
                                            
                                            dbRef = db.collection("Posts").addDocument(data: postData) { err in
                                                if err != nil {
                                                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "error")
                                                }else{
                                                    self.postImage.image = UIImage(named: "defaultImage.jpg")
                                                    self.comment.text = ""
                                                    self.placeName.text = ""
                                                    self.tabBarController?.selectedIndex = 0
                                                }
                                            }
                                        }

                                    }
                                    

                                }
                            }
                        }
                    }
                }
            }
            
            
            animateButton(uploadButton)
        }else {
            self.showAlert(title: "Error", message: "Plase fill all fields")
        }
    }



    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Post fotoğrafı ekleme
    @objc private func addPostImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            self.postImage.image = editedImage
        }
        self.dismiss(animated: true)
    }
    
    private func setupUI() {
        // Arka plan gradient ekleme
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)

        // Buton stil ayarı
        uploadButton.layer.cornerRadius = 10
        uploadButton.layer.shadowColor = UIColor.black.cgColor
        uploadButton.layer.shadowOpacity = 0.2
        uploadButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        uploadButton.layer.shadowRadius = 2
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.backgroundColor = .systemGreen

        // ImageView stil ayarı
        postImage.layer.cornerRadius = 10
        postImage.layer.masksToBounds = true
        postImage.layer.borderWidth = 2
        postImage.layer.borderColor = UIColor.systemGray4.cgColor
        postImage.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addPostImage))
        postImage.addGestureRecognizer(gestureRecognizer)

        // TextField stil ayarları
        placeName.layer.cornerRadius = 10
        placeName.layer.masksToBounds = true
        placeName.layer.borderWidth = 1
        placeName.layer.borderColor = UIColor.systemGray4.cgColor
        placeName.attributedPlaceholder = NSAttributedString(
            string: "Place Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        placeName.delegate = self

        comment.layer.cornerRadius = 10
        comment.layer.masksToBounds = true
        comment.layer.borderWidth = 1
        comment.layer.borderColor = UIColor.systemGray4.cgColor
        comment.attributedPlaceholder = NSAttributedString(
            string: "Comment",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        comment.delegate = self

        // MapView stil ayarı
        mapView.layer.cornerRadius = 10
        mapView.layer.masksToBounds = true
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = UIColor.systemGray4.cgColor
        mapView.delegate = self

        // Klavye kapatma için gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // Klavye return tuşuna basıldığında klavyeyi kapat
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                button.transform = CGAffineTransform.identity
            }
        }
    }
}




