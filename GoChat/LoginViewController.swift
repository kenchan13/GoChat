//
//  LoginViewController.swift
//  GoChat
//
//  Created by Ken Chan on 2017/4/14.
//  Copyright © 2017年 KenChan. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //anonymousButton:
        //Set border color and width
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        GIDSignIn.sharedInstance().clientID = "732248735520-qgpnue7pq69d3m0piopg1mjaaidgpb4j.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymouslyDidTapped(_ sender: Any) {
        print("Login anonymously did tapped")
        // Anonymously log users in
        // switch view by setting navigation controller as root view controller
        
        Helper.helper.loginAnonymously()
        
    }

    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("Google login did tapped")
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        print(user.authentication)
        Helper.helper.logInWithGoogle(user.authentication)
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
