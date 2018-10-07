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
    private var taskIdToPhotoBtnTag = [Int: Int]()
    
    // keeps track of user's console selections
    private lazy var consolesSelected: [String: String]? = {
        guard let consoles = User.onlineUser.consoles else { return nil }
        var dict = consoles
        return dict
    }()
    
    private lazy var updateConsoleSelectionView: UpdateConsoleSelectionView  = {
        var view = UpdateConsoleSelectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cancelBtn.tag = 0
        view.cancelBtn.addTarget(self,
                                 action: #selector(cancelBtnPressed(sender:)),
                                 for: .touchUpInside)
        view.updateBtn.addTarget(self,
                                 action: #selector(updateConsolesBtnPressed(sender:)),
                                 for: .touchUpInside)
        return view
    }()
    private lazy var updateBioView: UpdateBioView = {
        var view = UpdateBioView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cancelBtn.tag = 1
        view.cancelBtn.addTarget(self,
                                 action: #selector(cancelBtnPressed(sender:)),
                                 for: .touchUpInside)
        view.updateBtn.addTarget(self,
                                 action: #selector(updateBioBtnPressed(sender:)),
                                 for: .touchUpInside)
        return view
    }()
    private lazy var uploadImagesProfileView: UploadImagesForProfileView = {
        var view = UploadImagesForProfileView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.closeBtn.tag = 2
        view.closeBtn.addTarget(self,
                                action: #selector(cancelBtnPressed(sender:)),
                                for: .touchUpInside)
        
        for (index, btn) in view.imageBtns.enumerated() {
            btn.addTarget(self,
                          action: #selector(imageBtnPressed(sender:)),
                          for: .touchUpInside)
            
            // retrieve the url and download the image
            guard let url = profileImagesIDToUrlTupleArray?[index].1,
                url != "" else { continue }
            let id = manager.downloadImage(from: url)
            guard let taskId = id else { continue }
            taskIdToPhotoBtnTag[taskId] = btn.tag
        }
        
        for btn in view.uploadBtns {
            btn.addTarget(self,
                          action: #selector(uploadImageBtnPressed(sender:)),
                          for: .touchUpInside)
            btn.isEnabled = false
        }
        return view
    }()
    
    private let section0Titles = ["Change Consoles Played", "Change Games Played"]
    private let section1Titles = ["Update Bio", "Upload Images"]
    private let section2Titles = ["Notifications"]
    
    private lazy var userRef: DatabaseReference? = {
        guard let uid = User.onlineUser.uid else { return nil }
        return Database.database().reference().child("Users/\(uid)/")
    }()
    private lazy var userCacheInfoRef: DatabaseReference? = {
        guard let uid = User.onlineUser.uid else { return nil }
        return Database.database().reference().child("UserCacheInfo/\(uid)/")
    }()
    
    private lazy var profileImagesIDToUrlTupleArray: [(String,String)]? = {
        guard let dict = User.onlineUser.profileImagesURLS else { return nil }
        var arr = Array(repeating: ("",""), count: 3)

        for (index, value) in dict.enumerated() {
            arr[index] = value
        }
        return arr
    }()
    
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
    
    
    // MARK: - UIViewController's Life cycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let rightBarBtn = UIBarButtonItem(title: "Logout", style: .plain, target: self,
                                         action: #selector(logoutUser(sender:)))
        navigationItem.rightBarButtonItem = rightBarBtn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc fileprivate func logoutUser(sender: UIBarButtonItem) {
        guard let vc = self.storyboard?
            .instantiateViewController(withIdentifier: signInVCIdentifier)
            as? LoginViewController else { return }
        let ac = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            FirebaseCalls.shared.logoutUser {
                self.present(vc, animated: true, completion: nil)
            }
        })
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    @objc fileprivate func cancelBtnPressed(sender: UIButton) {
        switch sender.tag {
        case 0:
            updateConsoleSelectionView.removeFromSuperview()
        case 1:
            updateBioView.removeFromSuperview()
        case 2:
            uploadImagesProfileView.removeFromSuperview()
            navigationController?.navigationBar.isHidden = false
            tabBarController?.tabBar.isHidden = false
        default:
            return
        }
     
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
            self.manager.uploadImage(image: image, at: path, completion: { (urlString, error) in
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

// MARK: -  UpdateConsoleSelectionView's Functions
extension ProfileSettingsViewController {
    fileprivate func setupUpdateConsoleSelectionView() {
        for btn in updateConsoleSelectionView.consoleBtns {
            btn.addTarget(self, action: #selector(consoleBtnPressed(sender:)), for: .touchUpInside)
        }
        
        for (index, consoleName) in updateConsoleSelectionView.btnTagToConsoleDict! {
            guard ((consolesSelected?[consoleName]) != nil) else { continue }
            updateConsoleSelectionView.consoleBtns[index].isSelected = true
        }
        
        view.addSubview(updateConsoleSelectionView)
        
        updateConsoleSelectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        updateConsoleSelectionView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        updateConsoleSelectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateConsoleSelectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc fileprivate func consoleBtnPressed(sender: UIButton) {
        guard let consoleName = updateConsoleSelectionView
            .btnTagToConsoleDict?[sender.tag] else { return }
        
        if let _ = consolesSelected?[consoleName] {
            sender.isSelected = false
            consolesSelected?.removeValue(forKey: consoleName)
        } else {
            sender.isSelected = true
            consolesSelected?[consoleName] = "true"
        }
    }
    
    @objc fileprivate func updateConsolesBtnPressed(sender: UIButton) {
        guard let ref = userRef?.child("Consoles/") else { return }
    
        FirebaseCalls.shared.removeAndUpdateReferenceWithDictionary(ref: ref,
                                                           values: consolesSelected)
        User.onlineUser.consoles = consolesSelected
        updateConsoleSelectionView.removeFromSuperview()
    }
    
}

// MARK: - UpdateBioView's Functions
extension ProfileSettingsViewController {
    fileprivate func setupUpdateBioView() {
        updateBioView.bioTextView.text = User.onlineUser.bio
        view.addSubview(updateBioView)
        
        updateBioView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        updateBioView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        updateBioView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateBioView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc fileprivate func updateBioBtnPressed(sender: UIButton) {
        guard let ref = userRef else { return }
        // verify text is not short and empty
        
        let text = updateBioView.bioTextView.text
        FirebaseCalls.shared.updateReferenceWithDictionary(ref: ref, values: ["bio": text!])
        User.onlineUser.bio = text
        updateBioView.removeFromSuperview()
    }
}

// MARK: - UploadImagesForProfileView's Functions
extension ProfileSettingsViewController {
    fileprivate func setupUploadImagesForProfileView() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        guard let size = delegate?.window?.frame.size else { return }
        
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(uploadImagesProfileView)
        
        uploadImagesProfileView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        uploadImagesProfileView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        uploadImagesProfileView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uploadImagesProfileView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func removeImageReference(index: Int) {
        guard let (imageId, url) = self.profileImagesIDToUrlTupleArray?[index],
            url != "" else { return }
        guard let uid = User.onlineUser.uid else { return }
        let referencePath = "Users/\(uid)/ProfileImages/\(imageId)"
        FirebaseCalls.shared.removeReferenceValue(at: referencePath)
        FirebaseCalls.shared.removeDataFromStorage(at: url)
    }
    
    @objc func uploadImageBtnPressed(sender: UIButton) {
        let index = sender.tag
        guard let image = uploadImagesProfileView
            .imageBtns[index].image(for: .normal) else { return }
        
        guard let uid = User.onlineUser.uid else { return }
        guard let ref = userRef?.child("ProfileImages/") else { return }
        let imageId = ref.childByAutoId().key
        let path = "profileImages/\(uid)/\(imageId).jpg"
     
        self.uploadImagesProfileView.uploadBtns[index].isEnabled = false
        manager.uploadImage(image: image, at: path, completion: { (urlString, error) in
            if let error = error {
                self.displayErrorMessage(with: error.localizedDescription)
                self.uploadImagesProfileView.uploadBtns[index].isEnabled = true
                return
            }
            guard let url = urlString else { return }
            FirebaseCalls.shared.updateReferenceList(ref: ref, values: [imageId: url])
            
            // remove previous picture from storage and reference in database
            self.removeImageReference(index: index)
        })
    }
    
    @objc func imageBtnPressed(sender: UIButton) {
        let index = sender.tag
        CamaraHandler.shared.imagePickedBlock = { image in
            sender.setImage(image, for: .normal)
            sender.layer.cornerRadius = 10
            sender.layer.masksToBounds = true
            self.uploadImagesProfileView.uploadBtns[index].isEnabled = true
        }
        CamaraHandler.shared.showActionSheet(vc: self)
    }
}

// MARK: - UITableViewDelegate
extension ProfileSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexpath selected : \(indexPath)")
        let (section, row) = (indexPath.section, indexPath.row)
        
        switch (section, row) {
        case (0,0):
            print("Change consoles played pressed")
            setupUpdateConsoleSelectionView()
        case (0,1):
            print("Change games played pressed")
        case (1,0):
            print("Change bio pressed")
            setupUpdateBioView()
        case (1,1):
            print("Upload images pressed")
            setupUploadImagesForProfileView()
        case (2,0):
            print("Notifications pressed")
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITableViewDataSource
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

extension ProfileSettingsViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                guard let btnIndex = self.taskIdToPhotoBtnTag[taskId]
                    else { return }
                let button = self.uploadImagesProfileView.imageBtns[btnIndex]
                button.setImage(image, for: .normal)
                button.layer.cornerRadius = 10
                button.layer.masksToBounds = true
                
            }
        } catch let error {
            print(error)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}

























