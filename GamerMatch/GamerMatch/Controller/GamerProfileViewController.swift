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
    var user: UserJSONResponse?
    
    lazy var consolesDict: [String: Console]? = {
        guard let consoles = VideoGameRepo.shared.getConsoles()
            else { return nil}
        var dict = [String: Console]()
        
        for console in consoles {
            dict[console.name] = console
        }
        
        return dict
    }()
    
    lazy var gamesDict: [String: VideoGame]? = {
        guard let games = VideoGameRepo.shared.getVideoGames()
            else { return nil }
        var dict = [String: VideoGame]()
        
        for game in games {
            dict[game.title!] = game
        }
        
        return dict
    }()
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var userProfileImg: UIImageView! {
        didSet {
            userProfileImg.image = userImage != nil ? userImage
                : UIImage(named: "noAvatarImg")
            
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
        guard let id = userCacheInfo?.uid else { return }
        FirebaseCalls.shared.getUser(with: id) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.user = user
            self.setupConsoleImages()
            self.setupGameImages()
        }
    }
    
    fileprivate func setupConsoleImages() {
        guard let consolesOwn = user?.consoles else { return }
        for (counter, consoleName) in consolesOwn.enumerated() {
            print(consoleName.key)
            if let console = consolesDict?[consoleName.key] {
                consoleImgs[counter].image = console.notSelectedImage
            }
        }
    }
    
    fileprivate func setupGameImages() {
        guard let gamesOwn = user?.games else { return }
        for (counter, gameName) in gamesOwn.enumerated() {
            print(gameName)
            if let game = gamesDict?[gameName.key] {
                gameImgs[counter].image = game.notSelectedImage
            }
        }
    }
    
    fileprivate func setupRoleImages() {
        
    }
    
    @objc fileprivate func addGamerBtnPressed(sender: UIButton) {
        print("gamer btn pressed")
    }

}
