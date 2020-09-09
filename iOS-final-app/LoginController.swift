//
//  ViewController.swift
//  iOS-final-app
//
//  Created by Aditya Bhati on 4/16/20.
//  Copyright © 2020 Aditya Bhati. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        passwordTextField.isSecureTextEntry = true
        loginButton.layer.cornerRadius = 10
    }
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        logUserIn(withEmail: email, password: password)
    }
    //MARK: - API
    @IBAction func signUpTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToSignup", sender: self)
    }
    
    func logUserIn(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                self.shakeForIncorrect()
                print("Failed to sign user in with the error ", error.localizedDescription)
                return
            }
            
            self.performSegue(withIdentifier: "loginToApp", sender: LoginController())
        }
    }
    
    func shakeForIncorrect() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: passwordTextField.center.x - 10, y: passwordTextField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: passwordTextField.center.x + 10, y: passwordTextField.center.y))
        passwordTextField.layer.add(animation, forKey: "position")
    }
}



   
