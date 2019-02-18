//
//  ViewController.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 1/30/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import UIKit
import JGProgressHUD
import BRYXBanner

class ViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var aboutUsButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    //MARK: - Main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        bgView.layer.cornerRadius = 15
        aboutUsButton.layer.cornerRadius = 16
        
        checkConnection { (status, statusCode) in
            if statusCode == 404{
                print("herererere")
                let title = "No connection"
                let subtitle = "Connect to Internet,then restart app"
                let banner = Banner(title: title, subtitle: subtitle, backgroundColor: .red)
                banner.springiness = .slight
                banner.position = .top
                banner.dismissesOnTap = false
                banner.show()
            }else{
                print("connection existing")
                self.UpdateDataFromDatabase()
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func abiutTapped(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AboutUsViewController") as? AboutUsViewController else{
            fatalError("couldnt initialize vc")
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Function
    func UpdateDataFromDatabase(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Updating data from database"
        hud.show(in: self.view)
        
        let teamId = UserDefaults.standard.object(forKey: KTEAM) as! String
        FetchTeamDetails(teamid: teamId) { (team, status) in
            if team != nil{
                hud.dismiss(animated: true)
                let teamEntered = team!.teamIdEntrd!
                let endGame = team!.endgame!
                let initTimeStamp = team!.timestamp!
                
                print(teamEntered)
                print(endGame)
                print(initTimeStamp)
                
                UserDefaults.standard.set(teamEntered, forKey: KTEAMIDENTRD)
                UserDefaults.standard.set(endGame, forKey: KENDGAME)
                UserDefaults.standard.set(initTimeStamp, forKey: KINITIALTIMESTAMP)
                UserDefaults.standard.synchronize()
            }else{
                let alert = UIAlertController(title: "Error", message: "Connection required to update data from database", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                    self.UpdateDataFromDatabase()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    

}

