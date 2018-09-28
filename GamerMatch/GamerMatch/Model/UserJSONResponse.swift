//
//  UserJSONResponse.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/27/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation

struct UserJSONResponse: Decodable {
    let uid: String
    let username: String
    let email: String
    let bio: String?
    let isOnline: String
    let url: String
    let consoles: [String: String]
    let games: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case uid = "uid"
        case username = "username"
        case email = "email"
        case bio = "bio"
        case isOnline = "isOnline"
        case url = "url"
        case consoles = "Consoles"
        case games = "Games"
    }
}



