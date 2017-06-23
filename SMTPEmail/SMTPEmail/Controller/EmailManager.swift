//
//  EmailManager.swift
//  SMTPEmail
//
//  Created by Malik on 6/23/17.
//  Copyright © 2017 Jignesh. All rights reserved.
//

import UIKit
import MBProgressHUD

class EmailManager: NSObject {
    static let shared = EmailManager()

    
    func getSMTP() -> MCOSMTPSession{
        let smtpSession = MCOSMTPSession()
        let token = UserDefaults.standard.value(forKey: "authToken") as? String ?? ""
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = email
        smtpSession.password = nil
        smtpSession.oAuth2Token = token
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.xoAuth2
        smtpSession.connectionType = MCOConnectionType.TLS
        return smtpSession
    }
    
    func sendMail(to: String, from:String, subject:String, body:String, completion: @escaping ((_ success:Bool, _ error: Error?) -> Void)) {
    
        let name = UserDefaults.standard.value(forKey: "name") as? String ?? ""
        let smtpSession = self.getSMTP()
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "", mailbox: to)]
        builder.header.from = MCOAddress(displayName: name, mailbox: from)
        builder.header.subject = subject
        builder.htmlBody = body
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
}


