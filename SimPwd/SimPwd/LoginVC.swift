//
//  LoginVC.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/18/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signIn(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if usernameField.text == nil || usernameField.text == "" {
            return
        }
        if passwordField.text == nil || passwordField.text == "" {
            return
        }
        let success = AppDelegate.signIn(username: usernameField.text!, password: passwordField.text!)
        if success {
            print ("- Auth: Login Successed")
            self.performSegue(withIdentifier: "showMainScreen", sender: self)
        } else {
            print ("- Auth: Login Failed")
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if usernameField.text == nil || usernameField.text == "" {
            return
        }
        if passwordField.text == nil || passwordField.text == "" {
            return
        }
        AppDelegate.createAccount(username: usernameField.text!, password: passwordField.text!)
    }

    @IBAction func clearCoreData(_ sender: Any) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        AppDelegate.clearData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainScreen" {
            let dest = segue.destination as! MainVC
            dest.username = usernameField.text!
        }
    }
}

