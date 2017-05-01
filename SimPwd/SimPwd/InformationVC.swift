//
//  InformationVC.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/27/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

class InformationVC: UIViewController {
    var login = Login()
    var username = ""
    var masterKey = ""
    var iv = ""
    
    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        self.siteField.text = self.login.site
        self.usernameField.text = self.login.username
        let key = Array(self.masterKey.utf8).sha256()
        let iv = Array(self.iv.utf8)
        let aes = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7())
        let encryptedData = NSData(base64Encoded: login.password, options: [])!
        let count = encryptedData.length / MemoryLayout<UInt8>.size
        var encrypted = [UInt8](repeating: 0, count: count)
        encryptedData.getBytes(&encrypted, length:count * MemoryLayout<UInt8>.size)
        let decryptedData = try! aes.decrypt(encrypted)
        let decryptedString = String(bytes: decryptedData, encoding: String.Encoding.utf8)
        self.passwordField.text = decryptedString
        
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        AppDelegate.getAllLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func deleteLogin(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if AppDelegate.deleteLogin(username: self.username, site: login.site, login: login.username) {
            self.navigationController?.popViewController(animated: true)
        } else {
            print ("Delete Login: Failed")
        }
    }
    
    @IBAction func generate(_ sender: Any) {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 16 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        passwordField.text = randomString
    }
    
    @IBAction func updateLogin(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let key = Array(self.masterKey.utf8).sha256()
        let iv = Array(self.iv.utf8)
        let aes = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7())
        var plainPassword = ""
        if passwordField.text! != "" {
            plainPassword = passwordField.text!
        }
        let cipher = try! aes.encrypt(Array(plainPassword.utf8))
        let base64encrypted = cipher.toBase64()
        if siteField.text! != "" && usernameField.text! != "" && passwordField.text! != "" {
            if (AppDelegate.updateLogin(username: self.username, site: self.siteField.text!, loginId: self.usernameField.text!, loginPw: base64encrypted!)) {
                print ("- Add Login: Success")
                self.navigationController?.popViewController(animated: true)
            } else {
                print ("- Add Login: Failed")
            }
        } else {
            self.showAlert(title: "Error", message: "Please enter all information")
        }

    }
}
