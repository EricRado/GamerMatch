//
//  SideMenuTopTableViewCell.swift
//  GamerMatch
//
//  Created by Eric Rado on 4/27/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class SideMenuTopTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
