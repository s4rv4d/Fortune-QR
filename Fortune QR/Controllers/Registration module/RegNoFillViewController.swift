//
//  RegNoFillViewController.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 2/1/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import UIKit
import BRYXBanner
import JGProgressHUD

class RegNoFillViewController: UIViewController {
    
    //MARK: - Variables
    var regis = [String]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var registration1textfield: UITextField!
    @IBOutlet weak var registration2textfield: UITextField!
    @IBOutlet weak var registration3textfield: UITextField!
    @IBOutlet weak var startButtonView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SetupTextfield()
        ButtonSetup()
        observeNotification()
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
    
    //MARK: - Button view outlet function
    func ButtonSetup(){
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.Tapped))
        startButtonView.isUserInteractionEnabled = true
        startButtonView.addGestureRecognizer(tapGes)
    }
    
    @objc func Tapped(){
        print("Tapped")
        
        regis = []
        
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
                //validation
                if self.registration1textfield.text == "" && self.registration2textfield.text == "" && self.registration3textfield.text == ""{
                    print("provide bro")
                    let alert = UIAlertController(title: "Alert", message: "Atleast provide one registration number.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                        self.clearFields()
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else if self.registration1textfield.text == "" || self.registration2textfield.text == "" || self.registration3textfield.text == ""{
                    //validate
                    self.validate()
                }else{
                    self.validate()
                }
            }
        }
    }
    
    func validate() {
        
        //hud
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        
        do {
            var reg1 = ""
            var reg2 = ""
            var reg3 = ""
            if registration1textfield.text != ""{
                reg1 = try registration1textfield.validatedText(validationType: ValidatorType.username)
            }
            
            if registration2textfield.text != ""{
                 reg2 = try registration2textfield.validatedText(validationType: ValidatorType.username)
            }
            
            if registration3textfield.text != ""{
                 reg3 = try registration3textfield.validatedText(validationType: ValidatorType.username)
            }
            
            
            if reg1 != ""{
                regis.append(reg1)
            }
            
            if reg2 != ""{
                regis.append(reg2)
            }
            
            if reg3 != ""{
                regis.append(reg3)
            }
            
            print("array \(regis)")
            
            let values = [KMEMBERS:regis,KTEAMIDENTRD:true] as [String:Any]
            
            UserDefaults.standard.set(true, forKey: KTEAMIDENTRD)
            
            UpdateCurrentTeam(withValues: values) { (error) in
                if error == nil{
                    hud.dismiss(animated: true)
                    self.GoToApp()
                }else{
                    hud.dismiss(animated: true)
                    self.showAlert(for: error!.localizedDescription)
                }
            }
            
            print("ok")
            
            
        } catch(let error) {
            hud.dismiss(animated: true)
            print("error \((error as! ValidationError).message)")
            showAlert(for: (error as! ValidationError).message)
        }
    }
    
    func showAlert(for alert: String) {
        let alertController = UIAlertController(title: "Error", message: alert, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
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
extension RegNoFillViewController: UITextFieldDelegate{
    
    func SetupTextfield(){
        
        registration1textfield.delegate = self
        registration2textfield.delegate = self
        registration3textfield.delegate = self
        
        //for registration 1
        //image
        registration1textfield.backgroundColor = .clear
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let image1 = UIImage(named: "humansymbol")
        imageView.image = image1
        registration1textfield.leftView = imageView;
        registration1textfield.leftViewMode = .always
        
        //placeholder
        registration1textfield.tintColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration1textfield.textColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration1textfield.attributedPlaceholder = NSAttributedString(string: "Registration number 1", attributes: [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)])
        registration1textfield.layoutIfNeeded()
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRect(x: 0, y: 29, width: registration1textfield.frame.width, height: 1)
        bottomLayer.backgroundColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration1textfield.layer.addSublayer(bottomLayer)
        registration1textfield.borderStyle = .none
        
        //for registration 2
        //image
        registration2textfield.backgroundColor = .clear
        let imageView2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let image2 = UIImage(named: "humansymbol")
        imageView2.image = image2
        registration2textfield.leftView = imageView2;
        registration2textfield.leftViewMode = .always
        
        //placeholder
        registration2textfield.tintColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration2textfield.textColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration2textfield.attributedPlaceholder = NSAttributedString(string: "Registration number 2", attributes: [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)])
        registration2textfield.layoutIfNeeded()
        let bottomLayer2 = CALayer()
        bottomLayer2.frame = CGRect(x: 0, y: 29, width: registration2textfield.frame.width, height: 1)
        bottomLayer2.backgroundColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration2textfield.layer.addSublayer(bottomLayer2)
        registration2textfield.borderStyle = .none
        
        //for registration 3
        //image
        registration3textfield.backgroundColor = .clear
        let imageView3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        let image3 = UIImage(named: "humansymbol")
        imageView3.image = image3
        registration3textfield.leftView = imageView3;
        registration3textfield.leftViewMode = .always
        
        //placeholder
        registration3textfield.tintColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration3textfield.textColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration3textfield.attributedPlaceholder = NSAttributedString(string: "Registration number 3", attributes: [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)])
        registration3textfield.layoutIfNeeded()
        let bottomLayer3 = CALayer()
        bottomLayer3.frame = CGRect(x: 0, y: 29, width: registration3textfield.frame.width, height: 1)
        bottomLayer3.backgroundColor = #colorLiteral(red: 1, green: 0.9725490196, blue: 0.9411764706, alpha: 1)
        registration3textfield.layer.addSublayer(bottomLayer3)
        registration3textfield.borderStyle = .none
        
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
        self.registration1textfield.text = ""
        self.registration2textfield.text = ""
        self.registration3textfield.text = ""
    }
}
