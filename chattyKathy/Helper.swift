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
import GoogleSignIn

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        Auth.auth().signInAnonymously { (anonUser, error) in
            if error == nil {
                self.switchViewToNVC()
            } else {
                print("Error in loggin in anonymously - error: \(String(describing: error))")
            }
        }
    }
    
    func loginWithGoogle(authentication: GIDAuthentication) {
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("could not authenticate google user, error: \(String(describing: error))")
            } else {
                self.switchViewToNVC()
            }
        }
    }
    
    private func switchViewToNVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }
}
