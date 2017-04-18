//
//  MainVC.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/18/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import Foundation
import UIKit

class MainVC: UIViewController, UITableViewDelegate {
    
    var username = "";
    
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
}

class LoginInfoViewCell: UITableViewCell {
    
}
