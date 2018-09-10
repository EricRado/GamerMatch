//
//  Message.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/9/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

struct Message: Decodable{
    let id: String?
    let senderId: String?
    let body: String?
    let timestamp: String?
    
    init(id: String, senderId: String, body: String, timestamp: String){
        self.id = id
        self.body = body
        self.senderId = senderId
        self.timestamp = timestamp
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: String] else{return nil}
        guard let id = dict["id"] else { return nil }
        guard let body = dict["body"] else {return nil}
        guard let senderId = dict["senderId"] else {return nil}
        guard let timestamp = dict["timestamp"] else {return nil}
        
        self.id = id
        self.body = body
        self.senderId = senderId
        self.timestamp = timestamp
    }
    
    
    func toAnyObject() -> [AnyHashable: Any]{
        return ["id": id!,"body": body!, "senderId": senderId!, "timestamp": timestamp!] as [AnyHashable: Any]
    }
}
