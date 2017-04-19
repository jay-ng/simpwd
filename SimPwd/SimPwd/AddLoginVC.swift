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
    
    @IBOutlet weak var siteField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.isNavigationBarHidden = false
        //self.navigationController?.title = "Login Information"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(_ sender: Any) {
    }
    
    @IBAction func generate(_ sender: Any) {
        var letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< 8 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        passwordField.text = randomString
        
    }

    @IBAction func clear(_ sender: Any) {
    }
    
}
