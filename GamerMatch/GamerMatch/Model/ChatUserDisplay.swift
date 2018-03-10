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
    var username: String?
    var userPic: UIImage?
    
    init(username: String, userPic: UIImage){
        self.username = username
        self.userPic = userPic
    }
}
