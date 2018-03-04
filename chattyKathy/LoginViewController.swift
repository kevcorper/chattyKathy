//
//  LoginViewController.swift
//  chattyKathy
//
//  Created by Kevin Perkins on 3/2/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginAnonymouslyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginAnonymouslyButton.layer.borderWidth = 2.0
        loginAnonymouslyButton.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAnonymouslyDidTapped(_ sender: Any) {
        Auth.auth().signInAnonymously { (anonUser, error) in
            if error == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVC
            } else {
                print("Error in loggin in anonymously - error: \(String(describing: error))")
            }
        }
    }
    
    
    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("googleLoginDidTapped")
    }
    
}
