//
//  VideoGame.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/19/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation
import UIKit

enum VideoGameType {
    case xbox
    case playstation
    case pc
}

struct VideoGame {
    var notSelectedImage:UIImage?
    var selectedImage: UIImage?
    var gameTypes =  [VideoGameType]()
}
