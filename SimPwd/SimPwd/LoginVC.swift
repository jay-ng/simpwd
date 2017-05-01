//
//  LoginVC.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/18/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import UIKit
import CryptoSwift

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        AppDelegate.getAllAccount()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            self.signIn(self)
        }
        // Do not add a line break
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // SignIn button activated
    @IBAction func signIn(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // User input safety check
        if usernameField.text! != "" && passwordField.text! != "" {
            let success = AppDelegate.signIn(username: usernameField.text!, password: passwordField.text!)
            if success {
                print ("- Auth: Login Successed")
                self.performSegue(withIdentifier: "showMainScreen", sender: self)
            } else {
                print ("- Auth: Login Failed")
                self.showAlert(title: "Login", message: "Username and Password not recognized")
            }
        } else {
            self.showAlert(title: "Error", message: "Please enter both username and password")
        }
    }
    
    // CreateAccount activated
    @IBAction func createAccount(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Safety check
        if usernameField.text! != "" && passwordField.text! != "" {
            AppDelegate.createAccount(username: usernameField.text!, password: passwordField.text!)
        } else {
            self.showAlert(title: "Error", message: "Please enter both username and password")
        }
    }

    // Debug, clear coredata
    @IBAction func clearCoreData(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        AppDelegate.clearData()
    }
    
    // Prepare for transition, passing sensitive information to next view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if segue.identifier == "showMainScreen" {
            let masterKey =  passwordField.text!
            let dest = segue.destination as! MainVC
            // Pass username, masterkey, and IV fetched from coredata
            dest.username = usernameField.text!
            dest.masterKey = masterKey.sha256()
            dest.iv = AppDelegate.getIV(username: usernameField.text!)
        }
    }
}

