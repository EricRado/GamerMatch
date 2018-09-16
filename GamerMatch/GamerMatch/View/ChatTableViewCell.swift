//
//  chatTableViewCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 3/7/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatUserPic: UIImageView! {
        didSet {
            chatUserPic.layer.cornerRadius = chatUserPic.frame.height / 2
            chatUserPic.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var chatUsernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
