//
//  Chat.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/9/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import Firebase

struct Chat: Decodable {
    let id: String?
    let creatorId: String?
    var adminId: String?
    var title: String?
    let isGroupChat: Bool?
    var lastMessage: String?
    var members: [String: String]?
    var urlString: String?
    
    init(id: String, creatorId: String, isGroupChat: Bool, title: String, members: [String: String] ){
        self.id = id
        self.creatorId = creatorId
        self.adminId = creatorId
        self.isGroupChat = isGroupChat
        self.title = title
        self.lastMessage = ""
        self.members = members
    }
    
    init(id: String, creatorId: String, adminId: String, title: String, isGroupChat: Bool, lastMessage: String, members: [String: String], urlString: String = "") {
        self.id = id
        self.creatorId = creatorId
        self.adminId = adminId
        self.isGroupChat = isGroupChat
        self.title = title
        self.lastMessage = lastMessage
        self.members = members
        self.urlString = urlString
    }
    
    init?(snapshot: DataSnapshot){
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String? else { return nil }
        guard let adminId = dict["adminId"] as? String? else { return nil }
        guard let creatorId = dict["creatorId"] as? String? else { return nil }
        guard let title = dict["title"] as? String? else { return nil }
        guard let isGroupChat = dict["isGroupChat"] as? String else { return nil }
        guard let lastMessage = dict["lastMessage"] as? String else { return nil }
        guard let members = dict["members"] as? [String:String] else { return nil }
        guard let urlString = dict["url"] as? String? else { return nil }
        
        self.id = id
        self.adminId = adminId
        self.creatorId = creatorId
        self.title = title
        self.isGroupChat = isGroupChat.toBool()
        self.lastMessage = lastMessage
        self.members = members
        self.urlString = urlString
    }
    
    func toAnyObject() -> [AnyHashable: Any]{
        return ["id": id!, "creatorId": creatorId!, "title": title!, "isGroupChat": String(isGroupChat!), "lastMessage": lastMessage!, "members": members!] as [AnyHashable: Any]
    }
    
}
