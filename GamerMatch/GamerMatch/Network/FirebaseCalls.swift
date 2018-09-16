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
    
    func getUserCacheInfo(userId: String?,
                          completion: @escaping (UserCacheInfo?, Error?) -> Void) {
        
        guard let id = userId else { return }
        let userRef = userCacheInfoRef.child("\(id)/")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("Call coming from getUserCacheInfo")
            if let dict = snapshot.value as? [String: Any] {
                print(snapshot)
                do {
                    let jsonDict = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let userCacheInfo = try JSONDecoder().decode(UserCacheInfo.self, from: jsonDict)
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
    
    
}
