//
//  DisplayChatMetaDataViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/19/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class DisplayChatMetaDataViewController: UIViewController {
    
    private let cellId = "cellId"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: UserTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellId)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var groupImageButton: UIButton! {
        didSet {
            groupImageButton
                .setBackgroundImage(groupImage, for: .normal)
            groupImageButton.addTarget(
                self,
                action: #selector(imagePressed(sender:)),
                for: .touchUpInside)
         
        }
    }
    @IBOutlet weak var savePhotoButton: UIButton! {
        didSet {
            savePhotoButton.isEnabled = false
            savePhotoButton.setTitleColor(UIColor.lightGray, for: .disabled)
            savePhotoButton.addTarget(
                self, action: #selector(savePhotoBtnPressed(sender:)),
                for: .touchUpInside)
        }
    }
    
    var groupImage: UIImage?
    var chat: Chat?
    var members: [UserCacheInfo]?
    fileprivate var taskIdsToIndexPathDict: [Int: IndexPath]?
    
    lazy var chatRef: DatabaseReference? = {
        guard let id = chat?.id else { return nil }
        var ref = Database.database().reference().child("Chats/\(id)/")
        return ref
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        taskIdsToIndexPathDict = [Int: IndexPath]()
        navigationItem.title = "Chat Settings"
        members = [UserCacheInfo]()
        getUsers()
    }
    
    fileprivate func getUsers() {
        guard let dict = chat?.members else { return }
        for (key, _) in dict {
            FirebaseCalls.shared.getUserCacheInfo(for: key) { (member, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.members?.append(member!)
                let row = (self.members?.count)! - 1
                self.tableView.insertRows(at: [IndexPath(row: row, section: 1)], with: .none)
            }
        }
    }
    
    @objc fileprivate func savePhotoBtnPressed(sender: UIButton) {
        guard let id = chat?.id else { return }
        let path = "groupProfileImages/\(id).jpg"
        let ac = UIAlertController(title: "Upload new image",
                                   message: "Do you want to change the group picture to the selected one?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let image = self.groupImage else { return }
//            self.mediaManager.uploadImage(image: image, at: path){ (urlString, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//                guard let url = urlString else { return }
//                guard let ref = self.chatRef else { return }
//                FirebaseCalls.shared.updateReferenceWithDictionary(ref: ref, values: ["url": url])
//            }
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    @objc fileprivate func imagePressed(sender: UIButton) {
        CamaraHandler.shared.showActionSheet(vc: self)
        CamaraHandler.shared.imagePickedBlock = { (image) in
            self.groupImageButton.setBackgroundImage(image, for: .normal)
            self.savePhotoButton.isEnabled = true
            self.savePhotoButton.setTitleColor(UIColor.blue, for: .normal)
            self.groupImage = image
        }
    }
}

extension DisplayChatMetaDataViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let ac = UIAlertController(title: "Group name",
                                       message: "Do you want to change the name of the group?",
                                       preferredStyle: .alert)
            ac.addTextField(configurationHandler: nil)
            ac.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                guard let ref = self.chatRef else { return }
                guard let groupName = ac.textFields?.first?.text else { return }
                
                FirebaseCalls.shared.updateReferenceWithDictionary(ref: ref,
                                                                   values: ["title" : groupName])
                self.chat?.title = groupName
                self.tableView.reloadRows(at: [indexPath], with: .none)
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 50.0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 10
    }
}

extension DisplayChatMetaDataViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return members?.count ?? 0
        default:
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.font = UIFont(name: "ComicSansMS-Bold", size: 17)
            cell.textLabel?.text = chat?.title
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
        
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            as? UserTableViewCell else { return UITableViewCell() }
        guard let user = members?[indexPath.row] else { return UITableViewCell() }
        
        cell.usernameLabel.text = user.username
        guard let url = user.url, !url.isEmpty else {
            cell.userImageView.image = UIImage(named: "noAvatarImg")
            return cell
        }
        
//        let id = mediaManager.downloadImage(from: url)
//        guard let taskId = id else { return cell }
//        taskIdsToIndexPathDict?[taskId] = indexPath
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Group Name"
        case 1:
            return "Participants : \(chat?.members?.count ?? 0)"
        default:
            return nil
        }
    
    }
}
