//
//  MainVC.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/18/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import Foundation
import UIKit

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var username = ""
    var masterKey = ""
    var iv = ""
    private var logins = [Login]()
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logins.removeAll()
        populateLogin()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearLogin() {
        logins.removeAll()
    }
    
    func populateLogin() {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let results = AppDelegate.getLogin(username: self.username)
        for result in (results) {
            let aLogin = Login(site: result.value(forKey: "site") as! String, username: result.value(forKey: "loginId") as! String, password: result.value(forKey: "loginPw") as! String)
            logins.append(aLogin)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loginInfoCell") as! LoginInfoViewCell
        let row = indexPath.row
        print ("Debug: Site \(logins[row].site)")
        cell.siteName.text = logins[row].site
        cell.loginId.text = logins[row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        self.performSegue(withIdentifier: "showLoginInfo", sender: row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLoginInfo") {
            let index = sender as! Int
            let dest = segue.destination as! InformationVC
            dest.login = logins[index]
            dest.username = self.username
            dest.masterKey = self.masterKey
            dest.iv = self.iv
        }
        if (segue.identifier == "showAddLogin") {
            let dest = segue.destination as! AddLoginVC
            dest.username = self.username
            dest.masterKey = self.masterKey
            dest.iv = self.iv
        }
    }
    
    deinit {
        self.username = ""
        self.masterKey = ""
        self.iv = ""
        self.logins = [Login]()
        print ("- Deinit: Cleared Data")
    }

}

class LoginInfoViewCell: UITableViewCell {
    
    @IBOutlet weak var siteName: UILabel!
    @IBOutlet weak var loginId: UILabel!
}
