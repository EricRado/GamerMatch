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
    var userImg:UIImageView?
    
    static var onlineUser = User(image: UIImage(named: "noAvatarImg")!)
    private var dbRef = Database.database().reference()
    
    private init(image: UIImage){
        print("initializing img...")
        self.userImg?.image = image
    }
    
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
            User.onlineUser.self.loadUserImg()
        }
        
    }
    
    func loadUserImg() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        // setup URL with image file name appended
        if let pathComponent = url.appendingPathComponent("userProfileImage.jpg") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            
            // check if file exists in document directory folder
            if fileManager.fileExists(atPath: filePath){
                print("Image exists...")
                User.onlineUser.userImg = UIImageView(image: UIImage(contentsOfFile: filePath))
            }else {
                print("Image does not exist...")
                User.onlineUser.userImg = UIImageView(image: UIImage(named: "noAvatarImg"))
                print("IMAGE LOADED...")
            }
        }else {
            print("File path not available...")
        }
    }
    
}



