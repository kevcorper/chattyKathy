//
//  LoginViewController.swift
//  chattyKathy
//
//  Created by Kevin Perkins on 3/2/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginAnonymouslyDidTapped(_ sender: Any) {
        print("loginAnonymouslyDidTapped")
    }
    
    
    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("googleLoginDidTapped")
    }
    
}
