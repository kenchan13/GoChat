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
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        print("Login anonymously did tapped")
        // Anonymously log users in
        // switch view by setting navigation controller as root view controller
        
        FIRAuth.auth()?.signInAnonymously(completion: {(anonymousUser: FIRUser?, error: Error?) in
            if error == nil {
                print("User ID: \(anonymousUser!.uid)")
                
                let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
                newUser.setValue(["displayname": "anonymous", "id": "\(anonymousUser!.uid)","profileUrl": ""])
                
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }

    func logInWithGoogle(_ authentication: GIDAuthentication) {
        //This is where we get the Google authentication information afther the Google sign in
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: {(user: FIRUser?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print(user?.email as Any)
                print(user?.displayName as Any)
                print(user?.photoURL as Any)
                
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                newUser.setValue(["displayname": "\(user!.displayName!)", "id": "\(user!.uid)","profileUrl": "\(user!.photoURL!)"])
                
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
