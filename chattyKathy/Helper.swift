//
//  Helper.swift
//  chattyKathy
//
//  Created by Kevin Perkins on 3/4/18.
//  Copyright © 2018 Kevin Perkins. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
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
}
