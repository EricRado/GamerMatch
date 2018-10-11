//
//  User.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/7/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase


final class User: NSObject {
    var uid: String?
    var email: String?
    var username: String?
    var bio: String?
    var isOnline: Bool?
    var avatarURL: String?
    var userImg:UIImage?
    var consoles: [String: String]?
    var profileImagesURLS: [String: String]?
    
    static var onlineUser = User()
    
    private var dbRef = Database.database().reference()
    private lazy var manager: ImageManager = {
        var manager = ImageManager()
        manager.downloadSession = session
        return manager
    }()
    private lazy var session: URLSession = {
        var session = URLSession(configuration: .default,
                                 delegate: self, delegateQueue: nil)
        return session
    }()
    
    private override init(){}
    
    private init? (snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: Any] else {return}
        
        guard let uid = dict["uid"] as? String else {return nil}
        guard let email = dict["email"] as! String? else {return nil}
        guard let username = dict["username"] as! String? else {return nil}
        guard let bio = dict["bio"] as! String? else {return nil}
        guard let isOnline = dict["isOnline"] as! String? else {return nil}
        guard let avatarURL = dict["url"] as! String? else {return nil}
        guard let consoles = dict["Consoles"] as? [String: String] else { return nil }
        if let profileImagesURLS = dict["ProfileImages"] as? [String: String] {
            self.profileImagesURLS = profileImagesURLS
        }
        
        self.uid = uid
        self.email = email
        self.username = username
        self.bio = bio
        self.isOnline = isOnline.toBool()
        self.avatarURL = avatarURL
        self.consoles = consoles
        
    }
    
    func toAnyObject() -> [AnyHashable: Any] {
        return ["uid": uid!, "email": email!, "username": username!,
                "bio": bio!, "isOnline": String(isOnline!), "url":
                    avatarURL!] as [AnyHashable: Any]
    }
    
    func retrieveUserInfo(uid: String) {
        let userDBRef = dbRef.child("Users/\(uid)")
        let userCacheInfoRef = dbRef.child("UserCacheInfo/\(uid)")
        userDBRef.observeSingleEvent(of: .value) { (snapshot) in
            User.onlineUser = User(snapshot: snapshot)!
            User.onlineUser.self.loadUserImg()
        }
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: userDBRef,
                                           values: ["isOnline": "true"])
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: userCacheInfoRef,
                                           values: ["isOnline": "true"])
        
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
                _ = manager.downloadImage(from: urlString)
            }
        }
    }
}


extension User: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            User.onlineUser.userImg = UIImage(data: data)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
}





























