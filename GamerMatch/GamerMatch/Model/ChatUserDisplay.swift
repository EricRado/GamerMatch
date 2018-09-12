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
    let image: UIImage
    
    init(username: String, image: UIImage) {
        self.username = username
        self.image = image
    }
    
}
