//
//  UserModel.swift
//  Fortune QR
//
//  Created by Sarvad shetty on 1/30/19.
//  Copyright © 2019 Sarvad shetty. All rights reserved.
//

import Foundation
import FirebaseDatabase

//structure
//teamId
//duration(string)
//latestQrId(string)
//latestQrQ(string)
//members:[string]
//teamIdEntrd(Bool)
//timestamp(string)


//will need to persist

class User{
    
    //Database references
    var dbReference:DatabaseReference!
    
    
    //MARK: - Varibles
    let teamId:String
    var duration:String?
    var latestQrId:String?
    var latestQrQ:String?
    var members:[String]?
    var teamIdEntrd:Bool?
    var timestamp:String?
    var endgame:Bool?
    
    //MARK: - Initializers
    init(_teamId:String, _duration:String?, _latestQrId:String?, _latestQrQ:String?, _members:[String]?, _teamIdEntrd:Bool?, _timestamp:String?, _endgame:Bool?) {
        
        self.teamId = _teamId
        self.duration = _duration
        self.latestQrId = _latestQrId
        self.latestQrQ = _latestQrQ
        self.members = _members
        self.teamIdEntrd = _teamIdEntrd
        self.timestamp = _timestamp
        self.endgame = _endgame
    }
    
    //for updating
    init(_dictionary:NSDictionary) {
        self.teamId = _dictionary[KTEAMID] as! String
        
        if let dur = _dictionary[KDURATION]{
            self.duration = dur as? String
        }else{
            self.duration = ""
        }
        
        if let ltstQrId = _dictionary[KLATESTQRID]{
            self.latestQrId = ltstQrId as! String
        }else{
           self.latestQrId = ""
        }
        
        if let ltstQrQ = _dictionary[KLATESTQRQ]{
            self.latestQrQ = ltstQrQ as! String
        }else{
            self.latestQrQ = ""
        }
        
        if let mbrs = _dictionary[KMEMBERS]{
            self.members = mbrs as! [String]
        }else{
            self.members = []
        }
        
        if let tmIDEntd = _dictionary[KTEAMIDENTRD]{
            self.teamIdEntrd = tmIDEntd as! Bool
        }else{
            self.teamIdEntrd = false
        }
        
        if let tmstmp = _dictionary[KTIMESTAMP]{
            self.timestamp = tmstmp as! String
        }else{
            self.timestamp = ""
        }
        
        if let endgm = _dictionary[KENDGAME]{
            self.endgame = endgm as! Bool
        }else{
            self.endgame = false
        }
    }
}


//MARK: - functions
func FetchTeamDetails(teamid:String,completion:@escaping(_ team:User?,_ error:String)->Void){
    Database.database().reference().child(KTEAMID).child(teamid).observeSingleEvent(of: .value) { (snapshot) in
        //getting dictionary
        
        if !snapshot.exists(){
            print("here")
            completion(nil, "error getting data from database")
        }else{
            guard let teamDict = snapshot.value as? NSDictionary else{
                fatalError("couldnt get data")
                completion(nil,"error getting data from database")
            }
            print(teamDict)
            let team = User(_dictionary: teamDict)
            completion(team, "Success")
        }
    }
}

func UpdateCurrentTeam(withValues:[String:Any],completion:@escaping(_ error: Error?)->Void){
        let teamId = UserDefaults.standard.object(forKey: KTEAM) as! String
        //update firebase
        Database.database().reference().child(KTEAMID).child(teamId).updateChildValues(withValues) { (error,_)  in
            if error != nil{
                completion(error!)
                return
            }
            completion(error)
        }
}
