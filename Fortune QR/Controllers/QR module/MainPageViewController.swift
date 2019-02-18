//
//  MainPageViewController.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 2/1/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import UIKit
import BRYXBanner
import JGProgressHUD

class MainPageViewController: UIViewController {
    
    //MARK: - IBOutlets
    //countup timer
    @IBOutlet weak var countupTimerLabel: UILabel!
    @IBOutlet weak var cameraButtonView: UIImageView!
    
    //textview
    @IBOutlet weak var clueTextView: UITextView!
    
    //bottom button views
    @IBOutlet weak var aboutUsButtonView: UIImageView!
    @IBOutlet weak var endGameView: UIImageView!
    
    //MARK: - Variables
    //timer props
    var startTime = TimeInterval()
    var timer:Timer? = Timer()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //passed Data
    var passedData:String?
    var qrIdStr:String?
    var qrIdInt:Int?
    var prevQrId:Int?
    var clue:String?
    var values:[String:Any]?
    
    //MARK: - Main functions
    override func viewDidLoad() {
        super.viewDidLoad()
        QRTapgestureObserv()
        TextViewData()
        TapGestureObservations()
        
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
                self.StartStopWatch()
                self.UpdateDataFromDatabase()
            }
        }
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
                let prevId = team!.latestQrId!
                let prevIDInt = Int(prevId)
                
                print(teamEntered)
                print(endGame)
                
                UserDefaults.standard.set(teamEntered, forKey: KTEAMIDENTRD)
                UserDefaults.standard.set(endGame, forKey: KENDGAME)
                UserDefaults.standard.set(prevIDInt!, forKey: KPREVQRID)
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
    
    //MARK: - Timer functions
    func StartStopWatch(){
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(UpdateTime), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
   @objc func UpdateTime(){
        var currentTime = NSDate.timeIntervalSinceReferenceDate
        var elapsedTime: TimeInterval = currentTime - startTime
        print("elapsed time \(elapsedTime)")
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        
        let fraction = UInt8(elapsedTime * 100)
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        countupTimerLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    func StopCountup(){
        timer?.invalidate()
        //an object has to be an optional to be set as nil
        timer = nil
    }
    
    //MARK: - QR view functions
    func QRTapgestureObserv(){
        let qrtap = UITapGestureRecognizer(target: self, action: #selector(QRViewTapped))
        cameraButtonView.isUserInteractionEnabled = true
        cameraButtonView.addGestureRecognizer(qrtap)
    }
    
    func TapGestureObservations(){
        let aboutTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.AboutUsTapped))
        aboutUsButtonView.isUserInteractionEnabled = true
        aboutUsButtonView.addGestureRecognizer(aboutTapGesture)
        
        let endGameTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.EndGameTapped))
        endGameView.isUserInteractionEnabled = true
        endGameView.addGestureRecognizer(endGameTapGesture)
    }
    
    @objc func AboutUsTapped(){
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func EndGameTapped(){
        let alert = UIAlertController(title: "Notice", message: "Are you sure you want to end the game?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let endAction = UIAlertAction(title: "End Game", style: .destructive) { (_) in
            
            //hud
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            
            //update initial timestamp
            let initialTimestamp = "00:00:00"
            let prevData = 0
            UserDefaults.standard.set(prevData, forKey: KPREVQRID)
            UserDefaults.standard.set(initialTimestamp, forKey: KINITIALTIMESTAMP)
            UserDefaults.standard.set(true, forKey: KENDGAME)
            print("STORED DATEE IS \(UserDefaults.standard.string(forKey: KINITIALTIMESTAMP))")
            UserDefaults.standard.synchronize()
            
            let values = [KTIMESTAMP:initialTimestamp,KENDGAME:true] as [String:Any]
            //update database
            UpdateCurrentTeam(withValues: values) { (error) in
                if error == nil{
                    //progress here
                    hud.dismiss(animated: true)
                    //end game
                    DispatchQueue.main.async {
                        self.GoToEnd()
                    }
                }else{
                    print("3")
                    hud.dismiss(animated: true)
                    //error
                    let alert2 = UIAlertController(title: "Error", message: "Connection error", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(endAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func QRViewTapped(){
        print("qr tapped")
        
        checkConnection { (status, statusCode) in
            if statusCode == 404{
                print("herererere")
                let title = "No connection"
                let subtitle = "Make sure you have access to internet"
                let banner = Banner(title: title, subtitle: subtitle, backgroundColor: .red)
                banner.springiness = .slight
                banner.position = .top
                banner.dismissesOnTap = true
                banner.show()
            }else{
                print("connection existing")
                
                //present qr view
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func TextViewData(){
        if passedData != nil{
            print(passedData!)
        }
    }
    
    func GoToEnd(){
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "endNav") as! UINavigationController
        
        mainView.navigationBar.setBackgroundImage(UIImage(), for: .default)
        mainView.navigationBar.shadowImage = UIImage()
        mainView.navigationBar.backgroundColor = .clear
        mainView.navigationBar.isTranslucent = true
        
        self.appDelegate.window?.rootViewController = mainView
    }
    
    //unwind
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        if let sourceViewController = segue.source as? QRViewController {
            passedData = sourceViewController.dataToPass!
            print(passedData!)
            
            let splitData = passedData!.split(separator: "-")
            print(splitData)
            
            //string manipulation
            clue = String(splitData[1])
            let qrId = String(splitData[0])
            let inValQr = Int(qrId)
            
            qrIdStr = qrId
            qrIdInt = inValQr!
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.UpdateData()
        }
        
    }
    
    func UpdateData(){
        
        //hud
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)

        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let convertedDate: String = dateFormatter.string(from: currentDate) // 01:42:22 AM
        print("ini \(convertedDate)")
        
        let prev = UserDefaults.standard.integer(forKey: KPREVQRID)
        
        //for initial qr id only
        if (qrIdInt! == 1 && prev != 1) || (qrIdInt! == 10 && prev != 10) || (qrIdInt! == 18 && prev != 18) || (qrIdInt! == 19 && prev != 19) || (qrIdInt! == 28 && prev != 28) || (qrIdInt! == 37 && prev != 37){
            print("1")
            clueTextView.text = clue!
            
            UserDefaults.standard.set(convertedDate, forKey: KINITIALTIMESTAMP)
            print("STORED DATEE IS \(UserDefaults.standard.string(forKey: KINITIALTIMESTAMP))")
            UserDefaults.standard.synchronize()
            
            let ini = UserDefaults.standard.string(forKey: KINITIALTIMESTAMP)
            
            print("curr \(convertedDate)")
            print("ininini \(ini!)")
            let currDate = dateFormatter.date(from: convertedDate)
            let iniDate = dateFormatter.date(from: ini!)
            
            print("current date is \(currDate!)")
            print("ini data is \(iniDate!)")
            
            let diffIntMins = currDate!.minutes(sinceDate: iniDate!)
            var diffIntSec = currDate!.seconds(sinceDate: iniDate!)
            
            if diffIntSec! > 60{
                diffIntSec = diffIntSec! / 60
            }
            print("diff is \(diffIntMins!)")
            let diffStr = String(diffIntMins!) + " minutes " + "and \(diffIntSec!) seconds"
            print(diffStr)
            values = [KTIMESTAMP:convertedDate,KLATESTQRID:qrIdStr!,KLATESTQRQ:clue!,KDURATION:diffStr] as [String:Any]
            
            UpdateCurrentTeam(withValues: values!) { (error) in
                if error == nil{
                    //progress here
                    hud.dismiss(animated: true)
                    print("2")
                    print("success")
                    self.prevQrId = self.qrIdInt!
                    
                    UserDefaults.standard.set(self.qrIdInt!, forKey: KPREVQRID)
                    UserDefaults.standard.synchronize()
                    
                }else{
                    print("3")
                    hud.dismiss(animated: true)
                    //error occured
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry scan", style: .default, handler: { (_) in
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else if (qrIdInt! % 9 == 0) && (prev != 9 || prev != 18 || prev != 27 || prev != 36 || prev != 45){
            
            UserDefaults.standard.set(qrIdInt!, forKey: KPREVQRID)
            
            clueTextView.text = clue!
            print("last")
            let ini = UserDefaults.standard.string(forKey: KINITIALTIMESTAMP)
            
            print("curr \(convertedDate)")
            print("ininini \(ini!)")
            let currDate = dateFormatter.date(from: convertedDate)
            let iniDate = dateFormatter.date(from: ini!)
            
            print("current date is \(currDate!)")
            print("ini data is \(iniDate!)")
            
            let diffIntMins = currDate!.minutes(sinceDate: iniDate!)
            var diffIntSec = currDate!.seconds(sinceDate: iniDate!)
            
            if diffIntSec! > 60{
                diffIntSec = diffIntSec! / 60
            }
            print("diff is \(diffIntMins!)")
            let diffStr = String(diffIntMins!) + " minutes " + "and \(diffIntSec!) seconds"
            print(diffStr)
            
            //update initial timestamp
            let initialTimestamp = "00:00:00"
            let prevId = 0
            UserDefaults.standard.set(initialTimestamp, forKey: KINITIALTIMESTAMP)
            UserDefaults.standard.set(prevId, forKey: KPREVQRID)
            print("STORED DATEE IS \(UserDefaults.standard.string(forKey: KINITIALTIMESTAMP))")
            UserDefaults.standard.synchronize()
            
            values = [KTIMESTAMP:initialTimestamp,KLATESTQRID:qrIdStr!,KLATESTQRQ:clue!,KDURATION:diffStr] as [String:Any]
            //update database
            UpdateCurrentTeam(withValues: values!) { (error) in
                if error == nil{
                    //progress here
                    hud.dismiss(animated: true)
                    //end game
                    DispatchQueue.main.sync {
                        self.GoToEnd()
                    }
                }else{
                    print("3")
                    hud.dismiss(animated: true)
                    //error occured
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry scan", style: .default, handler: { (_) in
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            
            //check qr id
            if (qrIdInt! - 1) == prev{
                
                UserDefaults.standard.set(qrIdInt!, forKey: KPREVQRID)
                
                clueTextView.text = clue!
                print("last")
                let ini = UserDefaults.standard.string(forKey: KINITIALTIMESTAMP)
                
                print("curr \(convertedDate)")
                print("ininini \(ini!)")
                let currDate = dateFormatter.date(from: convertedDate)
                let iniDate = dateFormatter.date(from: ini!)
                
                print("current date is \(currDate!)")
                print("ini data is \(iniDate!)")
                
                let diffIntMins = currDate!.minutes(sinceDate: iniDate!)
                var diffIntSec = currDate!.seconds(sinceDate: iniDate!)
                
                if diffIntSec! > 60{
                    diffIntSec = diffIntSec! / 60
                }
                print("diff is \(diffIntMins!)")
                let diffStr = String(diffIntMins!) + " minutes " + "and \(diffIntSec!) seconds"
                print(diffStr)
                
                values = [KLATESTQRID:qrIdStr!,KLATESTQRQ:clue!,KDURATION:diffStr] as [String:Any]
                UpdateCurrentTeam(withValues: values!) { (error) in
                    if error == nil{
                        //progress here
                        hud.dismiss(animated: true)
                        
                    }else{
                        print("3")
                        hud.dismiss(animated: true)
                        //error occured
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Retry scan", style: .default, handler: { (_) in
                            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else if qrIdInt! == prev{
                hud.dismiss(animated: true)
                let alert = UIAlertController(title: "Notice", message: "You have already scanned this code", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (_) in
                    print("DJSD")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                hud.dismiss(animated: true)
                print("error")
                let alert = UIAlertController(title: "Notice", message: "You've seemed to skipped or repeated \(abs(qrIdInt! - prev)) tasks", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                    print("go back")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
