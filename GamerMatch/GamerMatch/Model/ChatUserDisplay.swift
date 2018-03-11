//
//  ChatUserDisplay.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/10/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

struct ChatUserDisplay: Hashable {
    var id: String?
    var username: String?
    var avatarURL: String?
    
    init(id: String, username: String, avatarURL: String){
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
    }
    
    var hashValue: Int {
        return (id?.hashValue)!
    }
    
    static func == (lhs: ChatUserDisplay, rhs: ChatUserDisplay) -> Bool {
        return lhs.id == rhs.id && lhs.username == rhs.username
            && lhs.avatarURL == rhs.avatarURL
    }
}
