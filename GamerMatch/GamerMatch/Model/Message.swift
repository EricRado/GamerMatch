//
//  Message.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/9/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

class Message{
    var body: String?
    var senderId: String?
    
    init(body: String, senderId: String){
        self.body = body
        self.senderId = senderId
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: String] else{return nil}
        guard let body = dict["body"] else {return nil}
        guard let senderId = dict["senderId"] else {return nil}
        
        self.body = body
        self.senderId = senderId
    }
    
    func toAnyObject() -> [AnyHashable: Any]{
        return ["body": body!, "senderId": senderId!] as [AnyHashable: Any]
    }
}
