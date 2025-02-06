import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SDWebImage


class ProfileVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var editProfileBut: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var bioText: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    var documentIDArray = [String]()
    var postArray = [String]()
    var selectedDocumentID = ""
    
    var profileImageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
        fetchPosts()
        
        userName.isEnabled = false
        bioText.isEditable = false
        saveButton.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        profilePhoto.image = UIImage(named: "defaultpp")
        
        profilePhoto.isUserInteractionEnabled = false
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addProfilePhoto))
        profilePhoto.addGestureRecognizer(gestureRecognizer)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = postArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         selectedDocumentID = self.documentIDArray[indexPath.row]
        performSegue(withIdentifier: "toDetalisVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetalisVC" {
            let destinationVC = segue.destination as! detalisVC
            destinationVC.chosenDocument = selectedDocumentID
        }
    }

    func fetchPosts() {
        if let currentUserEmail = Auth.auth().currentUser?.email {
        
            let db = Firestore.firestore()
            
            db.collection("Posts")
                .whereField("userEmail", isEqualTo: currentUserEmail)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else {
                        if let snapshot = snapshot, !snapshot.isEmpty {
                            self.documentIDArray.removeAll()
                            self.postArray.removeAll()
                            
                            for post in snapshot.documents {
                                
                                let documentID = post.documentID
                                self.documentIDArray.append(documentID)
                                
                                if let comment = post.get("comment") as? String {
                                    self.postArray.append(comment)
                                    print(comment)
                                }
                            }
                            self.tableView.reloadData()
                        } else {
                            print("Hiç post bulunamadı.")
                        }
                    }
                }
        }
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        userName.isEnabled = false
        bioText.isEditable = false
        saveButton.isHidden = true
        editProfileBut.isHidden = false
        editProfileBut.isEnabled = true
        profilePhoto.isUserInteractionEnabled = false
        editProfile()
    }
    


    @IBAction func logoutButtonClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLoginVC", sender: nil)
        }catch {
            self.showAlert(title: "Error", message: "Error")
        }
    }

    @IBAction func editProfileButtonClicked(_ sender: Any) {
        
      
        userName.isEnabled = true
        bioText.isEditable = true
        editProfileBut.isEnabled = false
        editProfileBut.isHidden = true
        saveButton.isHidden = false
        profilePhoto.isUserInteractionEnabled = true
        bioText.becomeFirstResponder()
    }


    
    
    
    
    
    func fetchData(){
        
        if let currentUser = Auth.auth().currentUser {
            
            self.userName.text = currentUser.email
            let db = Firestore.firestore()
            db.collection("Profiles").document(currentUser.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.userName.text = currentUser.email
                    self.bioText.text = data?["bio"] as? String ?? ""
                    
                    if let profilePhotoUrl = data?["profilePhotoUrl"] as? String {
                        self.profilePhoto.sd_setImage(with: URL(string: profilePhotoUrl), placeholderImage: UIImage(named: "defaultpp"))
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        
    }
    
    func editProfile(){
        if let currentUser = Auth.auth().currentUser {
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let mediaFolder = storageRef.child("ProfilePhoto")
            
            if let imageData = profilePhoto.image?.jpegData(compressionQuality: 0.3) {
                let imageRef = mediaFolder.child("\(currentUser.uid).jpg")
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if error != nil {
                        self.showAlert(title: "Error", message: error!.localizedDescription)
                    }else {
                        imageRef.downloadURL { url, error in
                            if error != nil {
                                self.showAlert(title: "Error", message: error!.localizedDescription)
                            }else {
                                if let imageDataUrl = url?.absoluteString {
                                    
                                    // update the profile data in Firestore
                                    let db = Firestore.firestore()
                                    let profileRef = db.collection("Profiles").document(currentUser.uid)
                                    
                                    let infoProfile = [
                                        
                                        "profilePhotoUrl": imageDataUrl,
                                        "bio": self.bioText.text!,
                                        "userEmail" : currentUser.email!
                                        
                                    ] as [String: Any]
                        
                                    profileRef.setData(infoProfile, merge: true) { error in
                                        if let error = error {
                                            self.showAlert(title: "Error", message: error.localizedDescription)
                                        } else {
                                            self.showAlert(title: "Success", message: "Profile updated successfully")
                                            
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
    
    
    


// Profil fotoğrafı ekleme
@objc func addProfilePhoto() {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    picker.allowsEditing = true
    present(picker, animated: true)
}
// UIImagePickerControllerDelegate için extension
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profilePhoto.image = editedImage
        }
        dismiss(animated: true)
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    


    // Klavye return tuşuna basıldığında klavyeyi kapat
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // TextView'da klavyeyi kapat
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    private func setupUI() {
        // Arka plan gradient ekleme
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)

        // Profil fotoğrafı stil ayarı
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2.9
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.borderColor = UIColor.systemGray4.cgColor
        


        // Buton stil ayarları
        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.shadowColor = UIColor.black.cgColor
        logoutButton.layer.shadowOpacity = 0.2
        logoutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoutButton.layer.shadowRadius = 4
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemRed

        editProfileBut.layer.cornerRadius = 10
        editProfileBut.layer.shadowColor = UIColor.black.cgColor
        editProfileBut.layer.shadowOpacity = 0.2
        editProfileBut.layer.shadowOffset = CGSize(width: 0, height: 2)
        editProfileBut.layer.shadowRadius = 4
        editProfileBut.setTitleColor(.white, for: .normal)
        editProfileBut.backgroundColor = .systemYellow
        
        saveButton.layer.cornerRadius = 10
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.2
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        saveButton.layer.shadowRadius = 4
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .green

        // TextField stil ayarı
        userName.layer.cornerRadius = 10
        userName.layer.masksToBounds = true
        userName.layer.borderWidth = 1
        userName.layer.borderColor = UIColor.systemGray4.cgColor
        userName.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        userName.delegate = self

        // TextView stil ayarı
        bioText.layer.cornerRadius = 10
        bioText.layer.masksToBounds = true
        bioText.layer.borderWidth = 1
        bioText.layer.borderColor = UIColor.systemGray4.cgColor
        bioText.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        bioText.delegate = self

    }
}
