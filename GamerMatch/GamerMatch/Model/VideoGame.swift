//
//  VideoGame.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/19/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

struct VideoGame {
    var title: String?
    var notSelectedImage:UIImage?
    var selectedImage: UIImage?
    var consoleTypes =  [ConsoleType]()
    var roles: [VideoGameRole]?
    
    init(title: String, notSelectedImage: UIImage, selectedImage: UIImage,
         consoleTypes: [ConsoleType], roles: [VideoGameRole]?) {
        self.title = title
        self.notSelectedImage = notSelectedImage
        self.selectedImage = selectedImage
        self.consoleTypes = consoleTypes
        self.roles = roles
    }
}
