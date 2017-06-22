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
            let alert = UIAlertController(title: "Error", message: "Please sign in first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { action in
            })
            self.present(alert, animated: true, completion: nil)
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
        let token = UserDefaults.standard.value(forKey: "authToken") as? String ?? ""
        let name = UserDefaults.standard.value(forKey: "name") as? String ?? ""
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = email
        smtpSession.password = nil
        smtpSession.oAuth2Token = token
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.xoAuth2
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: name, mailbox: "jigneshbodarya@gmail.com")]
        builder.header.from = MCOAddress(displayName: name, mailbox: email)
        builder.header.subject = "Hello from WithalSolution"
        builder.htmlBody = "Hello, this is jignesh's mail for being useful"
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            if (error != nil) {
                NSLog("Error sending email: \(String(describing: error))")
            } else {
                self.view.makeToast("Successfully sent email!")
                NSLog("Successfully sent email!")
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
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { action in
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
    }
    
}
