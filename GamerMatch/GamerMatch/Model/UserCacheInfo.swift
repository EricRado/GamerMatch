//
//  UserCacheInfo.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/11/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import Foundation

struct UserCacheInfo: Decodable {
    let uid: String?
    let username: String?
    let url: String?
    let isOnline: String?
}
