//
//  ChatUserDisplay.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/10/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

struct ChatUserDisplay {
    var id: String?
    var username: String?
    var avatarURL: String?
    
    init(id: String, username: String, avatarURL: String){
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
    }
}
