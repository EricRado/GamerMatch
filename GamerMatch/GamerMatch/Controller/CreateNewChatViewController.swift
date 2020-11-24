//
//  CreateNewChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase

class CreateNewChatViewController: UIViewController {
    var downloadSessionId: String?
    let groupSetupVCId = "NewGroupSetupVC"
    private let cellId = "cellId"
    
    let friendRef: DatabaseReference? = {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference().child("Friends/\(uid)/")
    }()
    
    lazy var selectedUsers: [String: UserCacheInfo] = {
        var users = [String: UserCacheInfo]()
        return users
    }()
    
    var existing1on1ChatUserIDToCache: [String: UserCacheInfo]?
    var existingChats: [Chat]?
    
    lazy var selectedUsersIdToUIImage: [String: UIImage] = {
        var dict = [String: UIImage]()
        return dict
    }()
    
    var friends: [UserCacheInfo]?
    private var taskIdToCellRowDict = [Int: Int]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            let nib = UINib(nibName: UserTableViewCell.identifier, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: cellId)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friends = [UserCacheInfo]()
        
        getUserFriends()
    }
    
    fileprivate func getUserFriends() {
        friendRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot]
                else { return }
            for child in snapshots {
                let id = child.key
                FirebaseCalls.shared.getUserCacheInfo(for: id) { userCacheInfo, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    guard let friend = userCacheInfo else { return }
                    self.friends?.append(friend)
                    guard let count = self.friends?.count else { return }
                    self.tableView.insertRows(at: [IndexPath(row: count - 1, section: 0)],
                                              with: .none)
                }
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
}

// MARK: - UITableView DataSource
extension CreateNewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = friends?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserTableViewCell else { return UITableViewCell()}
        
        guard let friend = friends?[indexPath.row] else { return cell }
        cell.usernameLabel.text = friend.username
        
//        if let url = friend.url, !url.isEmpty {
//            let id = mediaManager?.downloadImage(from: url)
//            guard let taskId = id else { return cell }
//            taskIdToCellRowDict[taskId] = indexPath.row
//        } else {
//            cell.userImageView.image = UIImage(named: "noAvatarImg")
//        }
        
        return cell
    }
}
