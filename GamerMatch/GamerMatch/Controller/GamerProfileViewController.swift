//
//  GamerProfileViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/26/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class GamerProfileViewController: UIViewController {
    
    var userCacheInfo: UserCacheInfo?
    var userImage: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var userProfileImg: UIImageView! {
        didSet {
            userProfileImg.image = userImage
            userProfileImg.layer.cornerRadius = userProfileImg.frame.height / 2.0
            userProfileImg.clipsToBounds = true
        }
    }
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.text = userCacheInfo?.username
        }
    }
    @IBOutlet weak var addGamerBtn: UIButton! {
        didSet {
            addGamerBtn.addTarget(
                self,
                action: #selector(addGamerBtnPressed(sender:)),
                for: .touchUpInside)
        }
    }
    
    @IBOutlet var consoleImgs: [UIImageView]!
    @IBOutlet var gameImgs: [UIImageView]!
    @IBOutlet var roleImgs: [UIImageView]!
    @IBOutlet var userStoredImgs: [UIImageView]!
    
    @IBOutlet weak var userBioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        view.backgroundColor = UIColor.white
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = userCacheInfo?.username
        
        getUserDetails()
    }
    
    fileprivate func getUserDetails() {
        guard let id = userCacheInfo?.id else { return }
        FirebaseCalls.shared.getUser(with: id) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @objc fileprivate func addGamerBtnPressed(sender: UIButton) {
        print("gamer btn pressed")
    }

}
