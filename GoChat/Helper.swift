//
//  Helper.swift
//  GoChat
//
//  Created by Ken Chan on 2017/4/15.
//  Copyright © 2017年 KenChan. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        print("Login anonymously did tapped")
        // Anonymously log users in
        // switch view by setting navigation controller as root view controller
        
        FIRAuth.auth()?.signInAnonymously(completion: {(anonymousUser: FIRUser?, error: Error?) in
            if error == nil {
                print("User ID: \(anonymousUser!.uid)")
                
                self.switchToNavigationViewController()
                
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }

    func logInWithGoogle(_ authentication: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: {(user: FIRUser?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print(user?.email as Any)
                print(user?.displayName as Any)
                
                self.switchToNavigationViewController()
                
            }
        })
    }
    
    func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }
    
}
