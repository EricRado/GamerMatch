//
//  User.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/7/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase


final class User {
    var uid: String?
    var email: String?
    var username: String?
    var bio: String?
    var isOnline: Bool?
    var avatarURL: String?
    var userImg:UIImage?
    var chatIds: [String: String]?
    var friendsIds: [String: String]?
    
    static var onlineUser = User()
    private var dbRef = Database.database().reference()
    
    private init(){}
    
    private init? (snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: Any] else {return}
        guard let uid = dict["uid"] as! String? else {return nil}
        guard let email = dict["email"] as! String? else {return nil}
        guard let username = dict["username"] as! String? else {return nil}
        guard let bio = dict["bio"] as! String? else {return nil}
        guard let isOnline = dict["isOnline"] as! String? else {return nil}
        guard let avatarURL = dict["url"] as! String? else {return nil}
        
        if let friendsIds = dict["friends"] as? [String: String] {
            self.friendsIds = friendsIds
        }
        
        if let chatIds = dict["chatIds"] as? [String: String] {
            self.chatIds = chatIds
        }
        
        self.uid = uid
        self.email = email
        self.username = username
        self.bio = bio
        self.isOnline = isOnline.toBool()
        self.avatarURL = avatarURL
    }
    
    func toAnyObject() -> [AnyHashable: Any] {
        return ["uid": uid!, "email": email!, "username": username!,
                "bio": bio!, "isOnline": String(isOnline!), "url":
                    avatarURL!] as [AnyHashable: Any]
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
        let url = URL(fileURLWithPath: path)
        
        let pathComponent = url.appendingPathComponent("userProfileImage.jpg")
        print("this is path component : \(pathComponent)")
        
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        
        // check if file exists in document directory folder
        if fileManager.fileExists(atPath: filePath) {
            print("Image exists...")
            User.onlineUser.userImg = UIImage(contentsOfFile: filePath)
        } else {
            if let urlString = User.onlineUser.avatarURL {
                print("User avatarURL : \(urlString)")
                //ImageManager.shared.downloadImage(urlString: urlString)
            }
        }
    }
    
    
}



