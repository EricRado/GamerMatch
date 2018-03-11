//
//  User.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/7/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

extension String {
    func toBool() -> Bool? {
        switch self  {
        case "True", "true":
            return true
        case "False", "false":
            return false
        default:
            return nil
        }
        
    }
}

class User {
    var uid: String?
    var email: String?
    var password: String?
    var username: String?
    var bio: String?
    var isActive: Bool?
    var avatarURL: String?
    
    init(uid: String, email: String, password: String, username: String){
        self.uid = uid
        self.email = email
        self.password = password
        self.username = username
        self.bio = ""
        self.isActive = true
        self.avatarURL = ""
    }
    
    init? (snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: String] else {return}
        
        guard let uid = dict["uid"] else {return nil}
        guard let email = dict["email"] else {return nil}
        guard let password = dict["password"] else {return nil}
        guard let username = dict["username"] else {return nil}
        guard let bio = dict["bio"] else {return nil}
        guard let isActive = dict["isActive"] else {return nil}
        guard let avatarURL = dict["avatarURL"] else {return nil}
        
        self.uid = uid
        self.email = email
        self.password = password
        self.username = username
        self.bio = bio
        self.isActive = isActive.toBool()
        self.avatarURL = avatarURL
    }
    
    func toAnyObject() -> [AnyHashable: Any] {
        return ["uid": uid!, "email": email!, "password": password!,
                "username": username!, "bio": bio!, "isActive": String(isActive!), "avatarURL": avatarURL!] as [AnyHashable: Any]
    }
}



