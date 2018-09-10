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
    let body: String?
    let senderId: String?
    let timestamp: String?
    
    init(body: String, senderId: String, timestamp: String){
        self.body = body
        self.senderId = senderId
        self.timestamp = timestamp
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: String] else{return nil}
        guard let body = dict["body"] else {return nil}
        guard let senderId = dict["senderId"] else {return nil}
        guard let timestamp = dict["timestamp"] else {return nil}
        
        self.body = body
        self.senderId = senderId
        self.timestamp = timestamp
    }
    
    
    func toAnyObject() -> [AnyHashable: Any]{
        return ["body": body!, "senderId": senderId!, "timestamp": timestamp!] as [AnyHashable: Any]
    }
}
