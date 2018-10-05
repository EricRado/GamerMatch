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
    private let signInVCIdentifier = "signInVC"
    private var updateBioView = UpdateBioView()
    private let section0Titles = ["Change Consoles Played", "Change Games Played"]
    private let section1Titles = ["Update Bio", "Upload Images"]
    private let section2Titles = ["Notifications"]
    private let section3Titles = ["Logout"]
    
    private let userRef: DatabaseReference? = {
        guard let uid = User.onlineUser.uid else { return nil }
        return Database.database().reference().child("Users/\(uid)")
    }()
    private let userCacheInfoRef: DatabaseReference? = {
        guard let uid = User.onlineUser.uid else { return nil }
        return Database.database().reference().child("UserCacheInfo/\(uid)")
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rightBarBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self,
                                         action: #selector(logoutUser(sender:)))
        navigationItem.rightBarButtonItem = rightBarBtn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = ImageManager()
    }
    
    fileprivate func changeConsolesPlayed() {
        print("changeConsolesPlayed()")
        let presentView = UpdateConsoleSelectionView()
        presentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(presentView)
        
        presentView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        presentView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        presentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        presentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        presentView.cancelBtn.addTarget(self, action: #selector(cancelBtnPressed(sender:)), for: .touchUpInside)
        
    }
    
    fileprivate func updateBio() {
        //updateBioView = UpdateBioView()
        updateBioView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(updateBioView)
        
        updateBioView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        updateBioView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        updateBioView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateBioView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        updateBioView.cancelBtn.addTarget(self, action: #selector(cancelBtnPressed(sender:)), for: .touchUpInside)
    }
    
    fileprivate func uploadImages() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let size = delegate?.window?.frame.size else { return }
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        print("this is the size of window : \(size)")
        let presentView = UploadImagesForProfileView()
        presentView.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(presentView)
        
        presentView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        presentView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        presentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        presentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    @objc fileprivate func logoutUser(sender: UIBarButtonItem) {
        guard let vc = self.storyboard?
            .instantiateViewController(withIdentifier: signInVCIdentifier)
            as? LoginViewController else { return }
        let ac = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            FirebaseCalls.shared.logoutUser {
                print("presenting LoginViewController...")
                self.present(vc, animated: true, completion: nil)
            }
        })
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
       
    }
    
    @objc fileprivate func cancelBtnPressed(sender: UIButton) {
        print("cancel btn pressed")
        
        updateBioView.removeFromSuperview()
    }
    
    @objc fileprivate func changeUsernameBtnPressed(sender: UIButton) {
        guard let username = usernameTextView.text else { return }
        guard let ref1 = userRef else { return }
        guard let ref2 = userCacheInfoRef else { return }
        
        if username.isEmpty {
            print("no text")
            return
        }
        
        if !(6 ... 16 ~= username.count)  {
            displayErrorMessage(with: "Username should be from 6 - 16 characters")
            return
        }
        
        if username == User.onlineUser.username {
            print("same username")
            return
        }
        
        changeUsernameBtn.isUserInteractionEnabled = false
        FirebaseCalls.shared.checkIfUsernameExists(username) { (check, error) in
            if let error = error {
                self.displayErrorMessage(with: error.localizedDescription)
                return
            }
            guard let usernameExists = check else { return }
            if usernameExists {
                FirebaseCalls.shared
                    .updateReferenceWithDictionary(ref: ref1, values: ["username": username])
                FirebaseCalls.shared
                    .updateReferenceWithDictionary(ref: ref2, values: ["username": username])
            } else {
                self.displayErrorMessage(with: "Username is already taken")
                self.changeUsernameBtn.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc fileprivate func editBtnPressed(sender: UIButton) {
        guard let id = User.onlineUser.uid else { return }
        let path = "userProfileImages/\(id).jpg"
        guard let ref1 = userRef else { return }
        guard let ref2 = userCacheInfoRef else { return }
      
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexpath selected : \(indexPath)")
        let (section, row) = (indexPath.section, indexPath.row)
        
        switch (section, row) {
        case (0,0):
            print("Change consoles played pressed")
            changeConsolesPlayed()
        case (0,1):
            print("Change games played pressed")
        case (1,0):
            print("Change bio pressed")
            updateBio()
        case (1,1):
            print("Upload images pressed")
            uploadImages()
        case (2,0):
            print("Notifications pressed")
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension ProfileSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section0Titles.count
        case 1:
            return section1Titles.count
        case 2:
            return section2Titles.count
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


























