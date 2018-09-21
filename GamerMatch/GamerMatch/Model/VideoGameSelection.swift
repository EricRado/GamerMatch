//
//  VideoGameSelection.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/21/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation

enum Console {
    case Xbox
    case Playstion
    case PC
}

class VideoGameSelection {
    var videoGame: VideoGame
    var roles: [VideoGameRole]?
    
    init(videoGame: VideoGame, role: [VideoGameRole]) {
        self.videoGame = videoGame
        self.roles = role
    }
}
