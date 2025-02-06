//
//  ViewController.swift
//  elisca
//
//  Created by Bilal Aydın on 3.02.2025.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var createButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    @IBAction func signInClicked(_ sender: Any) {
        if emailText.text != "" && passwordText.text != "" {
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!){ result, error in
            
                if error != nil {
                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
                
            }
        }
    }

    @IBAction func singUpClicked(_ sender: Any) {
      
        if emailText.text != "" && passwordText.text != "" {
            
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { results, error in
                if error != nil {
                    self.showAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                }else {
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }

    }



    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        // Arka plan gradient ekleme
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)

        // TextField stil ayarları
        emailText.layer.cornerRadius = 10
        emailText.layer.masksToBounds = true
        emailText.layer.borderWidth = 1
        emailText.layer.borderColor = UIColor.systemGray4.cgColor
        emailText.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        emailText.delegate = self

        passwordText.layer.cornerRadius = 10
        passwordText.layer.masksToBounds = true
        passwordText.layer.borderWidth = 1
        passwordText.layer.borderColor = UIColor.systemGray4.cgColor
        passwordText.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        passwordText.delegate = self

        // Buton stil ayarları
        signInButton.layer.cornerRadius = 10
        signInButton.layer.shadowColor = UIColor.black.cgColor
        signInButton.layer.shadowOpacity = 0.2
        signInButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        signInButton.layer.shadowRadius = 4
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.backgroundColor = .systemBlue

        createButton.layer.cornerRadius = 10
        createButton.layer.shadowColor = UIColor.black.cgColor
        createButton.layer.shadowOpacity = 0.2
        createButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        createButton.layer.shadowRadius = 4
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .systemGreen

        // Klavye kapatma için gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

