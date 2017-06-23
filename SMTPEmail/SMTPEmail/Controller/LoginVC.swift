//
//  LoginVC.swift
//  SMTPEmail
//
//  Created by Malik on 6/22/17.
//  Copyright © 2017 Jignesh. All rights reserved.
//

import UIKit
import GoogleSignIn
import MBProgressHUD

class LoginVC: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        self.signInButton.layer.cornerRadius = 5.0
        self.signInButton.layer.borderColor = UIColor.lightGray.cgColor
        self.signInButton.layer.borderWidth = 1.0
        self.sendEmailButton.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*======================================================
     * Method Name: sendEmailButtonPressed
     * Parameter: sender: Any
     * Return Type: nil
     * Purpose: To handle send mail button
     *======================================================*/
    @IBAction func sendEmailButtonPressed(_ sender: Any) {
        if UserDefaults.standard.value(forKey: "authToken") != nil {
            self.sendEmail()
        } else {
            self.alert(message: "Please sign in first")
        }
    }
    
    /*======================================================
     * Method Name: signInButtonPressed
     * Parameter: sender: Any
     * Return Type: nil
     * Purpose: To google singIn
     *======================================================*/
    @IBAction func signInButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().scopes = ["https://mail.google.com/"]
        GIDSignIn.sharedInstance().signIn()
    }
    
    /*======================================================
     * Method Name: sendEmail
     * Parameter: nil
     * Return Type: nil
     * Purpose: To send mail
     *======================================================*/
    func sendEmail() {
        
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        let to = "jigneshbodarya@gmail.com"
        let subject = "Hello from WithalSolution"
        let body = "Hello, this is jignesh's mail for being useful"
        MBProgressHUD.showAdded(to: self.view, animated: true)
        EmailManager.shared.sendMail(to: to, from: email, subject: subject, body: body) { (isSuccess, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if isSuccess {
                self.view.makeToast("Successfully sent email!")
            } else {
                self.view.makeToast((error?.localizedDescription)!)
            }
        }
    }
    
    // MARK: - GIDSignInUIDelegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let token = user.authentication.accessToken
            UserDefaults.standard.set(token, forKey: "authToken")
            UserDefaults.standard.set(user.profile.name, forKey: "name")
            UserDefaults.standard.set(user.profile.email, forKey: "email")
            UserDefaults.standard.synchronize()
            self.signInButton.superview?.isHidden = true
            self.sendEmailButton.isHidden = false
        } else {
            self.alert(message: error.localizedDescription)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
    }
    
    func alert(message:String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { action in
        })
        self.present(alert, animated: true, completion: nil)
    }
}
