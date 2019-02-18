//
//  StartLoginViewController.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 2/1/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import UIKit
import BRYXBanner
import JGProgressHUD

class StartLoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var registrationButtonView: UIImageView!
    @IBOutlet weak var tmIdTextfield: UITextField!
    
    //MARK: - Variables
    var teamObj:User?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        observeNotification()
        BtnViewSetup()
        SetupTextfield()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkConnection { (status, statusCode) in
            if statusCode == 404{
                print("herererere")
                let title = "No connection"
                let subtitle = status
                let banner = Banner(title: title, subtitle: subtitle, backgroundColor: .red)
                banner.springiness = .slight
                banner.position = .top
                banner.dismissesOnTap = true
                banner.show()
            }else{
                print("connection existing")
            }
        }
    }
    
    
    //MARK: - ButtonView outlet functions
    func BtnViewSetup(){
        let tapRecog = UITapGestureRecognizer(target: self, action: #selector(BtnSetpFunc))
        registrationButtonView.isUserInteractionEnabled = true
        registrationButtonView.addGestureRecognizer(tapRecog)
    }
    
    @objc func BtnSetpFunc(){
        
        checkConnection { (status, statusCode) in
            if statusCode == 404{
                let title = "No connection"
                let subtitle = status
//                let banner = Banner(title: title, subtitle: subtitle, backgroundColor: .red,
                let banner = Banner(title: title, subtitle: subtitle, backgroundColor: .red)
                banner.springiness = .slight
                banner.position = .top
                banner.dismissesOnTap = true
                banner.show(duration:5.0)
            }else{
                print("connection existing")
                //validation
                if self.tmIdTextfield.text == ""{
                    //present alert
                    let alert = UIAlertController(title: "Error", message: "Team input field is empty, try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                        self.clearFields()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    //make a call to firebase
                    //check if teamentrd if false then go to reg page
                    //else go to main qr page
                    
                    guard let tmD = self.tmIdTextfield.text else{
                        fatalError("empty")
                        return
                    }
                    
                    //hud
                    let hud = JGProgressHUD(style: .dark)
                    hud.textLabel.text = "Loading"
                    hud.show(in: self.view)
                    
                    FetchTeamDetails(teamid: tmD) { (team,status) in
                        if status != "Success"{
                            hud.dismiss(animated: true)
                            //alert here
                            let alert = UIAlertController(title: "Error", message: status + ", check entered details.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                                self.clearFields()
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        }else{
                            print("team details are \(team)")
                            self.teamObj = team!
                            print("status \(String(describing: self.teamObj!.teamIdEntrd))")
                            
                            //store teamid
                            UserDefaults.standard.set(self.teamObj!.teamId, forKey: KTEAM)
                            UserDefaults.standard.set(self.teamObj!.endgame!, forKey: KENDGAME)
                            UserDefaults.standard.synchronize()
                            
                            let stat = self.teamObj!.teamIdEntrd!
                            print("team hererer \(stat)")
                            if !stat{
                                print("not entered")
                                //hud
                                hud.dismiss(animated: true)
                                //go to app
                                self.clearFields()
                                self.GoToReg()
                            }else{
                                print("entered")
                                //hud
                                hud.dismiss(animated: true)
                                self.clearFields()
                                
                                if self.teamObj!.endgame! == true{
                                    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "endNav") as! UINavigationController
                                    
                                    mainView.navigationBar.setBackgroundImage(UIImage(), for: .default)
                                    mainView.navigationBar.shadowImage = UIImage()
                                    mainView.navigationBar.backgroundColor = .clear
                                    mainView.navigationBar.isTranslucent = true
                                    
                                    self.appDelegate.window?.rootViewController = mainView
                                }else{
                                    //GO TO MAIN PAGE
                                    self.GoToApp()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Main functions
    func GoToReg(){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegNoFillViewController") as! RegNoFillViewController
        //add extra if needed
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func GoToApp(){
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNav") as! UINavigationController
        
        mainView.navigationBar.setBackgroundImage(UIImage(), for: .default)
        mainView.navigationBar.shadowImage = UIImage()
        mainView.navigationBar.backgroundColor = .clear
        mainView.navigationBar.isTranslucent = true
        
        self.appDelegate.window?.rootViewController = mainView
    }
}

//MARK: - Extensions
extension StartLoginViewController: UITextFieldDelegate{
    
    //MARK: - UI Functions
    func SetupTextfield(){
        tmIdTextfield.delegate = self

        //image
        tmIdTextfield.backgroundColor = .clear
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let image1 = UIImage(named: "pencildesign")
        imageView.image = image1
        tmIdTextfield.leftView = imageView;
        tmIdTextfield.leftViewMode = .always
        
        //placeholder
        tmIdTextfield.tintColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        tmIdTextfield.textColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        tmIdTextfield.attributedPlaceholder = NSAttributedString(string: "Team ID", attributes: [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)])
        tmIdTextfield.layoutIfNeeded()
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 29, width: tmIdTextfield.frame.width, height: 1)
        bottomLayer.backgroundColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        tmIdTextfield.layer.addSublayer(bottomLayer)
        tmIdTextfield.borderStyle = .none
    }
    
    //MARK:Textfield notification properties
    func observeNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShow(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: -170, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
        
    }
    @objc func keyboardWillHide(){
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func clearFields(){
        self.tmIdTextfield.text = ""
    }

}
