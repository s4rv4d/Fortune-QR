//
//  AppDelegate.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 1/30/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //other edits
         UIApplication.shared.statusBarStyle = .lightContent
        
        //set up keyboard
        UITextField.appearance().keyboardAppearance = .dark
        
        //set up nav bar
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        //firebase configuration
        FirebaseApp.configure()
        
        //check if user already logged in
        if UserDefaults.standard.object(forKey: KTEAM) != nil{
            
            print(UserDefaults.standard.bool(forKey: KTEAMIDENTRD))
            
            if UserDefaults.standard.bool(forKey: KTEAMIDENTRD) == true{
                let endGameState = UserDefaults.standard.bool(forKey: KENDGAME)
                print(endGameState)
                if !endGameState{
                    self.GoToMain()
                }else{
                    //go to end game
                    DispatchQueue.main.async {
                        self.GoToEnd()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.GoToReg()
                }
            }
        }else{
            DispatchQueue.main.async {
                self.GoToReg()
            }
        }
        return true
    }
    
    func GoToMain(){
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNav") as! UINavigationController
        
        mainView.navigationBar.setBackgroundImage(UIImage(), for: .default)
        mainView.navigationBar.shadowImage = UIImage()
        mainView.navigationBar.backgroundColor = .clear
        mainView.navigationBar.isTranslucent = true
        mainView.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.window?.rootViewController = mainView
    }
    
    func GoToEnd(){
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "endNav") as! UINavigationController
        
        mainView.navigationBar.setBackgroundImage(UIImage(), for: .default)
        mainView.navigationBar.shadowImage = UIImage()
        mainView.navigationBar.backgroundColor = .clear
        mainView.navigationBar.isTranslucent = true
        mainView.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.window?.rootViewController = mainView
    }
    
    func GoToReg(){
        let regView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "regNav") as! UINavigationController
        
        regView.navigationBar.setBackgroundImage(UIImage(), for: .default)
        regView.navigationBar.shadowImage = UIImage()
        regView.navigationBar.backgroundColor = .clear
        regView.navigationBar.isTranslucent = true
        regView.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.window?.rootViewController = regView
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
       let startTime = UserDefaults.standard.object(forKey: "times") as! TimeInterval
        UserDefaults.standard.set(startTime, forKey: "timecnt")
        UserDefaults.standard.synchronize()
    }


}

