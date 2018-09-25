//
//  FriendRequest.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/25/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation

struct FriendRequest: Decodable {
    let id: String?
    let message: String?
    let fromId: String?
    let toId: String?
    let accepted: String?
    let rejected: String?
    let timestamp: String?
    
}
