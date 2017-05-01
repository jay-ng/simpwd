//
//  AppDelegate.swift
//  SimPwd
//
//  Created by Huy Nguyen on 4/18/17.
//  Copyright © 2017 Jay Ng. All rights reserved.
//

import UIKit
import CoreData
import CryptoSwift
import Foundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var Account : [NSManagedObject]? = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SimPwd")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // CoreData Function Implementation
    
    // Create a master account
    func createAccount(username: String, password: String) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomStringIV = ""
        
        // Generate a 16 bytes IV for AES, it is fixed per master account
        // User does not need to know his IV key
        for _ in 0 ..< 16 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomStringIV += NSString(characters: &nextChar, length: 1) as String
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let auth = NSEntityDescription.entity(forEntityName: "Auth", in: managedContext)!
        let account = NSManagedObject(entity: auth,
                                     insertInto: managedContext)
        print ("- Main Account: For \(username), with password: \(password), IV: \(randomStringIV)")
        
        // Set key-value pair
        account.setValue(username, forKey: "username")
        account.setValue(password.sha256(), forKey: "password")
        account.setValue(randomStringIV, forKey: "iv")
        
        // Save context
        do {
            try managedContext.save()
            print ("- Main Account: Created")
        } catch let error {
            print ("- CoreData: Could not save context. Error: \(error)")
        }
    }
    
    // Signin Check
    func signIn(username: String, password: String) -> Bool {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        // Get context
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Auth")
        fetchRequest.returnsObjectsAsFaults = false
        
        // Password is hashed using SHA256, then compare to hash stored in coredata
        // Return true if matched, false if not
        do {
            let account = try managedContext.fetch(fetchRequest)
            for acc in (account) {
                if (username == acc.value(forKey: "username") as! String) {
                    if (password.sha256() == acc.value(forKey: "password") as! String) {
                        return true
                    }
                }
            }
        } catch let error {
            print ("- CoreData: Could not fetch context. Error: \(error)")
        }
        
        
        return false
    }
    // Debug function, clear all coredata tuples
    func clearData() {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetchAuth = NSFetchRequest<NSFetchRequestResult>(entityName: "Auth")
        let fetchData = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        let requestAuth = NSBatchDeleteRequest(fetchRequest: fetchAuth)
        let requestData = NSBatchDeleteRequest(fetchRequest: fetchData)
        
        do {
            try managedContext.execute(requestAuth)
            try managedContext.save()
            try managedContext.execute(requestData)
            try managedContext.save()
            print ("- Debug: Core Data Cleared")
        } catch {
            print ("There was an error")
        }
    }
    
    // Get IV from core data
    func getIV(username: String) -> String {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return ""
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Auth")
        
        // Set Predicate
        let loginPredicate = NSPredicate(format: "username == %@", username)
        fetch.predicate = loginPredicate
        fetch.returnsObjectsAsFaults = false
        var iv = ""
        
        // Fetch
        do {
            let accounts = try managedContext.fetch(fetch)
            for acc in (accounts) {
                if (username == acc.value(forKey: "username") as! String) {
                    iv = acc.value(forKey: "iv") as! String
                }
            }
        } catch {
            print ("- CoreData: Can't fetch logins")
        }
        return iv
    }
    
    // Get all login predicated by a username
    func getLogin(username: String) -> [NSManagedObject] {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return [NSManagedObject]()
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Data")
        
        // Set predicate
        let loginPredicate = NSPredicate(format: "username == %@", username)
        fetch.predicate = loginPredicate
        fetch.returnsObjectsAsFaults = false
        
        // Fetch and return a set
        do {
            let logins = try managedContext.fetch(fetch)
            return logins
        } catch {
            print ("- CoreData: Can't fetch logins")
        }
        return [NSManagedObject]()
    }
    
    // Save a login
    func saveLogin(username: String, site: String, login: String, password: String) -> Bool {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let data = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
        let aLogin = NSManagedObject(entity: data,
                                      insertInto: managedContext)
        print ("- For \(username), Site: \(site), Login: \(login), Password: \(password)")
        
        // Set data and key for context
        aLogin.setValue(username, forKey: "username")
        aLogin.setValue(site, forKey: "site")
        aLogin.setValue(login, forKey: "loginId")
        aLogin.setValue(password, forKey: "loginPw")
        
        // Save the context after setting key-value pairs
        do {
            try managedContext.save()
            print ("- Account: Account Created")
            return true
        } catch let error {
            print ("- CoreData: Could not save context. Error: \(error)")
        }
        return false
    }

    // Delete a saved login
    func deleteLogin(username: String, site: String, login: String) -> Bool {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Data")
        
        // Set the predicate for CoreData Query
        let usernamePredicate = NSPredicate(format: "username == %@", username)
        let sitePredicate = NSPredicate(format: "site == %@", site)
        let loginPredicate = NSPredicate(format: "loginId == %@", login)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [usernamePredicate, sitePredicate, loginPredicate])
        fetch.predicate = compound
        fetch.returnsObjectsAsFaults = false
        
        // Fetch the query
        do {
            let logins = try managedContext.fetch(fetch)
            for login in (logins) {
                managedContext.delete(login)
            }
            try managedContext.save()
            print ("- CoreData: Delete Login Info Sucess")
            return true
        } catch {
            print ("- CoreData: Can't fetch logins")
        }
        return false
    }
    
    func updateLogin(username: String, site: String, loginId: String, loginPw: String) -> Bool {
        if deleteLogin(username: username, site: site, login: loginId) {
            if saveLogin(username: username, site: site, login: loginId, password: loginPw) {
                print ("- Login: Updated Login")
                return true
            }
        }
        return false
    }
    
    func getAllAccount() {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Auth")
        
        // Fetch and return a set
        do {
            let auth = try managedContext.fetch(fetch)
            for account in (auth) {
                let username = account.value(forKey: "username")!
                let password = account.value(forKey: "password")!
                let iv = account.value(forKey: "iv")!
                print ("- Master Account: \(username), \(password), \(iv)")
            }
        } catch {
            print ("- CoreData: Can't fetch master accounts")
        }
    }
    
    func getAllLogin() {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Data")
        
        // Fetch and return a set
        do {
            let data = try managedContext.fetch(fetch)
            for login in (data) {
                let username = login.value(forKey: "username")!
                let loginId = login.value(forKey: "loginId")!
                let loginPw = login.value(forKey: "loginPw")!
                let site = login.value(forKey: "site")!
                print ("- Login: \(username), \(site), \(loginId), \(loginPw)")
            }
        } catch {
            print ("- CoreData: Can't fetch master accounts")
        }
    }
    
}

class Account: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var iv: String
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
