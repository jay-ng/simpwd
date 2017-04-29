//
//  Login.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/27/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import Foundation

class Login {
    var site : String
    var username : String
    var password : String
    
    init() {
        self.site = "N/A"
        self.username = "N/A"
        self.password = "N/A"
    }
    
    init(site: String, username: String, password: String) {
        self.site = site
        self.username = username
        self.password = password
    }
    
}
