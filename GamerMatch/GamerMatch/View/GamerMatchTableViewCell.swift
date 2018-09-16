//
//  gamerMatchTableViewCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 6/28/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class GamerMatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gamerUsernameLabel: UILabel!
    @IBOutlet weak var gamerAvatarImageView: UIImageView! {
        didSet {
            gamerAvatarImageView.layer.cornerRadius = gamerAvatarImageView.frame.height / 2.0
            gamerAvatarImageView.clipsToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
