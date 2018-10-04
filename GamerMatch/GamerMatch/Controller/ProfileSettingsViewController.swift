//
//  ProfileSettingsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 10/3/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class ProfileSettingsViewController: UIViewController {
    private let cellId = "cellId"
    private let section0Titles = ["Change Consoles Played", "Change Games Played"]
    private let section1Titles = ["Change Bio", "Upload Images"]
    private let section2Titles = ["Notifications"]
    private let section3Titles = ["Logout"]
    
    private let userRef: DatabaseReference = {
        return Database.database().reference().child("Users/")
    }()
    private let userCacheInfoRef: DatabaseReference = {
        return Database.database().reference().child("UserCacheInfo/")
    }()
    
    private var manager: ImageManager?
    
    @IBOutlet weak var usernameTextView: UITextView! {
        didSet {
            usernameTextView.text = User.onlineUser.username
        }
    }
    @IBOutlet weak var userProfileImg: UIImageView! {
        didSet {
            userProfileImg.layer.cornerRadius = userProfileImg.frame.height / 2.0
            userProfileImg.layer.masksToBounds = true
            userProfileImg.image = User.onlineUser.userImg != nil ? User.onlineUser.userImg : UIImage(named: "noAvatarImg")
        }
    }
    @IBOutlet weak var editBtn: UIButton! {
        didSet {
            editBtn.addTarget(self,
                              action: #selector(editBtnPressed(sender:)),
                              for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var changeUsernameBtn: UIButton! {
        didSet {
            changeUsernameBtn.addTarget(self,
                                        action: #selector(changeUsernameBtnPressed(sender:)),
                                        for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = ImageManager()
    }
    
    @objc fileprivate func changeUsernameBtnPressed(sender: UIButton) {
        if usernameTextView.text.isEmpty {
            print("no text")
            return
        }
        
        if !(6 ... 16 ~= (usernameTextView.text?.count)!)  {
            displayErrorMessage(with: "Username should be from 6 - 16 characters")
            return
        }
        
        if usernameTextView.text == User.onlineUser.username {
            print("same username")
            return
        }
        
        
    }
    
    @objc fileprivate func editBtnPressed(sender: UIButton) {
        guard let id = User.onlineUser.uid else { return }
        let path = "userProfileImages/\(id).jpg"
        let ref1 = userRef.child("\(id)")
        let ref2 = userCacheInfoRef.child("\(id)")
      
        CamaraHandler.shared.imagePickedBlock = { image in
            self.userProfileImg.image = image
            self.manager?.uploadImage(image: image, at: path, completion: { (urlString, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let url = urlString else { return }
                FirebaseCalls.shared
                    .updateReferenceWithDictionary(ref: ref1, values: ["url": url])
                FirebaseCalls.shared
                    .updateReferenceWithDictionary(ref: ref2, values: ["url": url])
            })
        }
        CamaraHandler.shared.showActionSheet(vc: self)
    }

}

extension ProfileSettingsViewController: UITableViewDelegate {
    
}

extension ProfileSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section0Titles.count
        case 1:
            return section1Titles.count
        case 2:
            return section2Titles.count
        case 3:
            return section3Titles.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let (row, section) = (indexPath.row, indexPath.section)
        let title: String
        
        switch section {
        case 0:
            title = section0Titles[row]
        case 1:
            title = section1Titles[row]
        case 2:
            title = section2Titles[row]
        case 3:
            title = section3Titles[row]
        default:
            title = ""
        }
        
        cell.textLabel?.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 :
            return "Consoles and Game Management"
        case 1:
            return "Update Profile"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}


























