//
//  Chat.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/9/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

class Chat {
    var id: String?
    var creatorId: String?
    var title: String?
    var isGroupChat: Bool?
    
    init(id: String, creatorId: String){
        self.id = id
        self.creatorId = creatorId
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: String] else {return nil}
        guard let id = dict["id"] else {return nil}
        guard let creatorId = dict["creatorId"] else {return nil}
        guard let title = dict["title"] else {return nil}
        guard let isGroupChat = dict["isGroupChat"] else {return nil}
        
        self.id = id
        self.creatorId = creatorId
        self.title = title
        self.isGroupChat = isGroupChat.toBool()
    }
    
    func toAnyObject() -> [AnyHashable: Any]{
        return ["id": id!, "creatorId": creatorId!, "title": title!, "isGroupChat": String(isGroupChat!)] as [AnyHashable: Any]
    }
    
}
