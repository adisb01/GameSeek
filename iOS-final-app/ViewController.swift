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
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        //Get the defalt auth UI object
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else {
            // Log the error
            return
        }
        
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]
        let authViewController = authUI!.authViewController()
        
        present(authViewController, animated: true, completion: nil)
    }
    
}

extension ViewController: FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        //Check if there is an error
        if error != nil {
            //Log the error
            return
        }
        
        performSegue(withIdentifier: "goHome", sender: self)
        
    }
}


