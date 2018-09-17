//
//  CreateNewChatViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/17/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit

class CreateNewChatViewController: UIViewController {
    
    lazy var selectedUsers: [String: UserCacheInfo] = {
        var users = [String: UserCacheInfo]()
        return users
    }()
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration
            .background(withIdentifier: "CreateNewChatVCBgSessionConfiguration")
        let session = URLSession(configuration: configuration,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()
    
    var friends: [UserCacheInfo]?
    private var selectedUserIds: [String]?
    private let cellId = "cellId"
    private var taskIdToCellRowDict = [Int: Int]()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friends = [UserCacheInfo]()
        ImageManager.shared.downloadSession = downloadSession
        
        let nib = UINib(nibName: UserTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelection = true
        
        navigationItem.title = "New Chat"
        let item = UIBarButtonItem(title: "Create",
                                   style: .plain, target: self,
                                   action: #selector(createPressed(sender:)))
        navigationItem.rightBarButtonItem = item
        
        getUserFriends()
    }
    
    fileprivate func getUserFriends() {
        guard let friendIds = User.onlineUser.friendsIds else { return }
        
        for (id, _) in friendIds {
            FirebaseCalls.shared.getUserCacheInfo(for: id) { (userCacheInfo, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let friend = userCacheInfo else { return }
                self.friends?.append(friend)
                guard let row = self.friends?.count else { return }
                self.tableView.insertRows(at: [IndexPath(row: row - 1, section: 0)],
                                          with: .none)
            }
        }
    }
    
    @objc func createPressed(sender: UIBarButtonItem) {
        print("Create was pressed")
        print(selectedUsers)
        
    }

}

extension CreateNewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let friend = friends?[indexPath.row] else { return }
        selectedUsers[friend.id!] = friend
        print(selectedUsers)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselect")
        guard let friend = friends?[indexPath.row] else { return }
        selectedUsers.removeValue(forKey: friend.id!)
        print(selectedUsers)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 7
    }

}


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
        
        if let url = friend.avatarURL, !url.isEmpty {
            let id = ImageManager.shared.downloadImage(from: url)
            guard let taskId = id else { return cell }
            taskIdToCellRowDict[taskId] = indexPath.row
        } else {
            cell.userImageView.image = UIImage(named: "noAvatarImg")
            
        }
        
        return cell
    }
}

extension CreateNewChatViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            DispatchQueue.main.async {
                guard let row = self.taskIdToCellRowDict[taskId] else { return }
                guard let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? UserTableViewCell else { return }
                let image = UIImage(data: data)
                cell.userImageView.image = image
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































