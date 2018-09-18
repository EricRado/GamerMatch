//
//  FriendCollectionViewCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    static let identifier = "FriendCollectionViewCell"
    @IBOutlet weak var friendImageView: UIImageView! {
        didSet {
            friendImageView.layer.cornerRadius = friendImageView.frame.height / 2.0
            friendImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var friendUsernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
