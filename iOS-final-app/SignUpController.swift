//
//  SignUpController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/16/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//


import UIKit
import Firebase
import FirebaseUI
class SignUpController: UIViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        passwordTextField.isSecureTextEntry = true
        signUpButton.layer.cornerRadius = 10
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: - API
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        guard let username = usernameTextField.text, !email.isEmpty else { return }
        createUser(withEmail: email, password: password, username: username)
    }
    
    @IBAction func presentImageSelector(_ sender: Any) {
        print("image selected")
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //TODO: implement writing profile image to firebase
    func createUser(withEmail email: String, password: String, username: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            
            if let err = err {
                print("Failed to sign user up with the error ", err.localizedDescription)
                return
            }
            
            guard let uid = res?.user.uid else { return }
            
            let values = ["email": email, "username": username]
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    print("Failed to update database the error ", error.localizedDescription)
                    return
                }
                
                self.performSegue(withIdentifier: "signupToApp", sender: SignUpController())
            } )
        }
    }
}
