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
    
}
