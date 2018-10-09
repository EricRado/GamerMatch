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
    var roleImgCounter = 0
    private var taskIdToImageTag = [Int: Int]()
    
    private lazy var session: URLSession = {
        var session = URLSession(configuration: .default,
                                delegate: self,
                                delegateQueue: nil)
        return session
    }()
    private lazy var manager: ImageManager = {
        var manager = ImageManager()
        manager.downloadSession = session
        return manager
    }()
    
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
            guard let roles = game.roles else { continue }
            for role in roles {
                if var arr = rolesDict[role.roleName!] {
                    arr.append(role)
                    rolesDict[role.roleName!] = arr
                } else {
                    rolesDict[role.roleName!] = [role]
                }
            }
        }

        return dict
    }()
    
    lazy var rolesDict: [String: [VideoGameRole]] = {
        var dict = [String: [VideoGameRole]]()
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
    
    @IBOutlet var consoleImgs: [UIImageView]! {
        didSet {
            _ = consoleImgs.map { $0.isHidden = true }
        }
    }
    @IBOutlet var gameImgs: [UIImageView]! {
        didSet {
            _ = gameImgs.map { $0.isHidden = true }
        }
    }
    @IBOutlet var roleImgs: [UIImageView]!
    @IBOutlet var userStoredImgs: [UIImageView]! {
        didSet {
            for (index, image) in userStoredImgs.enumerated() {
                image.tag = index
            }
        }
    }
    
    @IBOutlet weak var userBioTextView: UITextView!
    
    
    // MARK: - UIViewController's lifecycle methods
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = userCacheInfo?.username
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        view.backgroundColor = UIColor.white
        
        getUserDetails()
    }
    
    fileprivate func getUserDetails() {
        guard let id = userCacheInfo?.uid else { return }
        FirebaseCalls.shared.getUser(with: id) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.user = user
            self.userBioTextView.text = self.user?.bio
            self.setupConsoleImages()
            self.setupGameImages()
            self.setupUserProfileImages()
        }
    }
    
    fileprivate func setupConsoleImages() {
        guard let consolesOwn = user?.consoles else { return }
        for (counter, consoleName) in consolesOwn.enumerated() {
            if let console = consolesDict?[consoleName.key] {
                consoleImgs[counter].image = console.notSelectedImage
                consoleImgs[counter].isHidden = false
            }
        }
    }
    
    fileprivate func setupGameImages() {
        guard let gamesOwn = user?.games else { return }
        for (counter, gameName) in gamesOwn.enumerated() {
            print(gameName)
            if let game = gamesDict?[gameName.key] {
                gameImgs[counter].image = game.notSelectedImage
                gameImgs[counter].isHidden = false
                if gameName.value != "noRole" {
                    setupRoleImages(game: game, roleStr: gameName.value)
                }
            }
        }
    }
    
    fileprivate func setupRoleImages(game: VideoGame, roleStr: String) {
        let splitRoleStr = roleStr.split(separator: ",")
        print("This is the splitRoleStr : \(splitRoleStr)")
        let roleStrArr = splitRoleStr.map { String($0) }
        print(roleStrArr)
        for roleStr in roleStrArr {
            guard let role = rolesDict[roleStr] else { continue }
            
            if role.count == 1 {
                roleImgs[roleImgCounter].image = role.first?.roleImg
            } else {
                // Traverse the games roles and select the role with
                // matching names
                let result = game.roles?.filter { $0.roleName == roleStr }
                roleImgs[roleImgCounter].image = result?.first?.roleImg
            }
            
            roleImgCounter += 1
        }
    }
    
    // storing images as imageID: urlString
    fileprivate func setupUserProfileImages() {
        guard let dict = user?.profileImageUrls else { return }
        for (index, value) in dict.enumerated() {
            let id = manager.downloadImage(from: value.1)
            guard let taskId = id else { return }
            taskIdToImageTag[taskId] = index
        }
    }
    
    fileprivate func createFriendRequest() {
        guard let userId = User.onlineUser.uid else { return }
        guard let friendId = userCacheInfo?.uid else { return }
        
        print("creating friend request")
        
        FirebaseCalls.shared
            .createFriendRequest(toId: friendId, fromId: userId, message: "Hellooooo") {
                print("friend request saved")
                self.displaySuccessfulMessage(with: "Friend Request sent")
                self.addGamerBtn.imageView?.alpha = 0.5
        }
    }
    
    @objc fileprivate func addGamerBtnPressed(sender: UIButton) {
        guard let userId = User.onlineUser.uid else { return }
        guard let friendId = userCacheInfo?.uid else { return }
        let path = "Friends/\(userId)/\(friendId)"
   
        FirebaseCalls.shared.checkIfReferencePathExists(path: path) { check, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if check! {
                print("Friend does exist")
                self.addGamerBtn.imageView?.alpha = 0.5
            } else {
                print("Friend does not exist")
                self.createFriendRequest()
            }
            self.addGamerBtn.isEnabled = false
        }
    }

}

extension GamerProfileViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        do {
            let data = try Data(contentsOf: location)
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                guard let imageTag = self.taskIdToImageTag[taskId]
                    else { return }
                let imageView = self.userStoredImgs[imageTag]
                imageView.image = image
                imageView.layer.cornerRadius = 10
                imageView.layer.masksToBounds = true
            }
        } catch let error {
            print(error)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}































