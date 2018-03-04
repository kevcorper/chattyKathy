//
//  LoginViewController.swift
//  chattyKathy
//
//  Created by Kevin Perkins on 3/2/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import UIKit

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
        Helper.helper.loginAnonymously()
    }
    
    
    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("googleLoginDidTapped")
    }
    
}
