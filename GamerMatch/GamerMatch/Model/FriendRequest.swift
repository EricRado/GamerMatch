//
//  FriendRequest.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/25/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation

struct FriendRequest: Codable {
    let id: String?
    let message: String?
    let fromId: String?
    let toId: String?
    let accepted: String?
    let rejected: String?
    let timestamp: String?
    
    init(id: String, fromId: String, toId: String, message: String, timestamp: String) {
        self.id = id
        self.fromId = fromId
        self.toId = toId
        self.message = message
        self.timestamp = timestamp
        self.accepted = "false"
        self.rejected = "false"
    }
}
