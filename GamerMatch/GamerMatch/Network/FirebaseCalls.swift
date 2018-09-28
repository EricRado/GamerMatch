//
//  FirebaseCalls.swift
//  GamerMatch
//
//  Created by Eric Rado on 6/10/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

class FirebaseCalls {
    let dbRef = Database.database().reference()
    
    lazy var userCacheInfoRef: DatabaseReference = {
        return dbRef.child("UserCacheInfo/")
    }()
    
    lazy var friendRequestRef: DatabaseReference = {
        return dbRef.child("FriendRequests/")
    }()
    
    lazy var userRef: DatabaseReference = {
        return dbRef.child("Users/")
    }()
    
    static var shared = FirebaseCalls()
    
    private init () {}
    
    func getIdListFromNode(for searchRef: DatabaseReference?,
                        completion: @escaping ([String]?, Error?) -> Void) {
        guard let ref = searchRef else { return }
        var ids = [String]()
        
        // retrieve data based on the database reference created
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if !snapshot.exists() {
                print("No gamer was found with specified criteria")
            }
            
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                print(snap)
                print(snap.key)
                ids.append(snap.key)
            }
            
            completion(ids, nil)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil, error)
        }
        
    }
    
    func getUserCacheInfo(for userId: String?,
                          completion: @escaping (UserCacheInfo?, Error?) -> Void) {
        
        guard let id = userId else { return }
        let userRef = userCacheInfoRef.child("\(id)/")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("Call coming from getUserCacheInfo")
            if let dict = snapshot.value as? [String: Any] {
                print(snapshot)
                do {
                    let jsonDict = try JSONSerialization
                        .data(withJSONObject: dict, options: [])
                    let userCacheInfo = try JSONDecoder()
                        .decode(UserCacheInfo.self, from: jsonDict)
                    completion(userCacheInfo, nil)
                } catch let error {
                    completion(nil, error)
                }
            } else {
                print("Snapshot is empty")
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFriendRequest(for id: String,
                          completion: @escaping (FriendRequest?, Error?) -> Void) {
        let ref = friendRequestRef.child("\(id)/")
    
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            do {
                let jsonDict = try JSONSerialization
                    .data(withJSONObject: dict, options: [])
                let friendRequest = try JSONDecoder()
                    .decode(FriendRequest.self, from: jsonDict)
                completion(friendRequest, nil)
            } catch let error {
                completion(nil, error)
            }
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func getUser(with id: String, completion: @escaping (UserJSONResponse?, Error?) -> Void) {
        let ref = userRef.child("\(id)/")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            do {
                let jsonDict = try JSONSerialization
                    .data(withJSONObject: dict, options: [])
                let user = try JSONDecoder().decode(UserJSONResponse.self, from: jsonDict)
                completion(user, nil)
            } catch let error {
                completion(nil, error)
            }
        }) { (error) in
            completion(nil, error)
        }
    }
    
    func updateReferenceList(ref: DatabaseReference, values: [String: String]?) {
        guard let dict = values else { return }
        for (key, value) in dict {
            ref.updateChildValues([key: value]) { (error, _) in
                if let error = error {
                    print(error.localizedDescription)
                    return 
                }
            }
        }
    }
    
    func updateReferenceWithDictionary(ref: DatabaseReference,
                                       values: [String: String]?) {
        guard let dict = values else { return }
        ref.updateChildValues(dict) { (error, _) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    
}
