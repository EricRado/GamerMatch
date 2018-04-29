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

final class User {
    var uid: String?
    var email: String?
    var password: String?
    var username: String?
    var bio: String?
    var isActive: Bool?
    var avatarURL: String?
    var userImg: UIImage?
    
    static var onlineUser = User()
    private var dbRef = Database.database().reference()
    
    private init(){}
    
    private init? (snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: Any] else {return}
        guard let uid = dict["uid"] as! String? else {return nil}
        guard let email = dict["email"] as! String? else {return nil}
        guard let password = dict["password"] as! String? else {return nil}
        guard let username = dict["username"] as! String? else {return nil}
        guard let bio = dict["bio"] as! String? else {return nil}
        guard let isActive = dict["isActive"] as! String? else {return nil}
        guard let avatarURL = dict["avatarURL"] as! String? else {return nil}
        
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
    
    func retrieveUserInfo(uid: String) {
        let userDBRef = dbRef.child("Users/\(uid)")
        userDBRef.observeSingleEvent(of: .value) { (snapshot) in
            User.onlineUser = User(snapshot: snapshot)!
        }
    }
    
    func retrieveUserProfilePic() {
        
    }
}



