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
    
    func createAccount(username: String, password: String) {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomStringIV = ""
        
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
        account.setValue(username, forKey: "username")
        account.setValue(password.sha256(), forKey: "password")
        account.setValue(randomStringIV, forKey: "iv")
        
        do {
            try managedContext.save()
            print ("- Main Account: Created")
        } catch let error {
            print ("- CoreData: Could not save context. Error: \(error)")
        }
    }
    
    func signIn(username: String, password: String) -> Bool {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Auth")
        fetchRequest.returnsObjectsAsFaults = false
        
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
    
    func getIV(username: String) -> String {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return ""
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Auth")
        let loginPredicate = NSPredicate(format: "username == %@", username)
        fetch.predicate = loginPredicate
        fetch.returnsObjectsAsFaults = false
        var iv = ""
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
    
    func getLogin(username: String) -> [NSManagedObject] {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return [NSManagedObject]()
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Data")
        let loginPredicate = NSPredicate(format: "username == %@", username)
        fetch.predicate = loginPredicate
        fetch.returnsObjectsAsFaults = false
        do {
            let logins = try managedContext.fetch(fetch)
            return logins
        } catch {
            print ("- CoreData: Can't fetch logins")
        }
        return [NSManagedObject]()
    }
    
    func saveLogin(username: String, site: String, login: String, password: String) -> Bool {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let data = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
        let aLogin = NSManagedObject(entity: data,
                                      insertInto: managedContext)
        print ("- For \(username), Site: \(site), Login: \(login), Password: \(password)")
        aLogin.setValue(username, forKey: "username")
        aLogin.setValue(site, forKey: "site")
        aLogin.setValue(login, forKey: "loginId")
        aLogin.setValue(password, forKey: "loginPw")
        
        do {
            try managedContext.save()
            print ("- Account: Account Created")
            return true
        } catch let error {
            print ("- CoreData: Could not save context. Error: \(error)")
        }
        return false
    }

    func deleteLogin(username: String, site: String, login: String) -> Bool {
        guard let AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = AppDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Data")
        let usernamePredicate = NSPredicate(format: "username == %@", username)
        let sitePredicate = NSPredicate(format: "site == %@", site)
        let loginPredicate = NSPredicate(format: "loginId == %@", login)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [usernamePredicate, sitePredicate, loginPredicate])
        fetch.predicate = compound
        fetch.returnsObjectsAsFaults = false
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
    
}

class Account: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var password: String
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
}
