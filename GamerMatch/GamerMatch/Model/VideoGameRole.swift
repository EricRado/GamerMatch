//
//  VideoGameRole.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/20/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

struct VideoGameRole {
    var roleName: String?
    var roleImg: UIImage?
    var selectedRoleImg: UIImage?
    
    init(roleName: String, roleImg: UIImage, selectedRoleImg: UIImage) {
        self.roleName = roleName
        self.roleImg = roleImg
        self.selectedRoleImg = selectedRoleImg
    }
}
