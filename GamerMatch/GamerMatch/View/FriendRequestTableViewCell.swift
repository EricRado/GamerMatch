//
//  FriendRequestTableViewCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/20/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {
    
    static let identifier = "FriendRequestTableViewCell"
    
    @IBOutlet weak var friendUsernameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView! {
        didSet {
            friendImageView.layer.cornerRadius = friendImageView.frame.height / 2.0
            friendImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var acceptFriendRequestBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
