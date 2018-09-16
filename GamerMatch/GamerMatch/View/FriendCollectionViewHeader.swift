//
//  FriendCollectionViewHeaderCollectionReusableView.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FriendCollectionViewHeader:
    UICollectionReusableView {
    
    static let identifier = "FriendCollectionViewHeader"
    @IBOutlet weak var friendStatusLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
}
