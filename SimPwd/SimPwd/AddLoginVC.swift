//
//  AddLoginVC.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/19/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

class AddLoginVC: UIViewController {
    
    var username = ""
    var masterKey = ""
    var iv = ""
    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var specialChars: UISwitch!
    @IBOutlet weak var passwordLength: UIStepper!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var lengthStepper: UIStepper!
    private var pwLength : Int = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lengthLabel.text = "Length: \(self.pwLength)"
        self.lengthStepper.autorepeat = true
        self.lengthStepper.maximumValue = 32
        self.lengthStepper.minimumValue = 8
        self.lengthStepper.value = 8
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let key = Array(self.masterKey.utf8).sha256()
        let iv = Array(self.iv.utf8)
        let aes = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7())
        let plainPassword = passwordField.text!
        let cipher = try! aes.encrypt(Array(plainPassword.utf8))
        let base64encrypted = cipher.toBase64()
        if (AppDelegate.saveLogin(username: self.username, site: self.siteField.text!, login: self.usernameField.text!, password: base64encrypted!)) {
            print ("- Add Login: Success")
            self.navigationController?.popViewController(animated: true)
        } else {
            print ("- Add Login: Failed")
        }
    }
    
    @IBAction func generate(_ sender: Any) {
        var letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let specials : NSString = "!@#$%^&"
        if specialChars.isOn {
            letters = letters.appendingFormat(specials)
        }
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< self.pwLength {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        passwordField.text = randomString
        
    }

    @IBAction func stepperClicked(_ sender: UIStepper) {
        self.pwLength = Int(sender.value)
        self.lengthLabel.text = "Length: \(self.pwLength)"
    }
    
    @IBAction func clear(_ sender: Any) {
        self.usernameField.text = ""
        self.passwordField.text = ""
        self.pwLength = 8
        self.lengthLabel.text = "Length: \(self.pwLength)"
    }
    
}
