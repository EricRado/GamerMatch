//
//  FriendsViewController.swift
//  GamerMatch
//
//  Created by Eric Rado on 9/16/18.
//  Copyright © 2018 Eric Rado. All rights reserved.
//

import UIKit
import Firebase


class FriendsViewController: UIViewController {
    
    private let cellId = "friendCell"
    private let vcIdentifier = "GamerProfileViewController"
    private let pendingFriendRequestString = "PendingFriendRequests/"
    private let onlineSectionId = 0
    private let offlineSectionId = 1
    
    private let friendRef: DatabaseReference = {
        return Database.database().reference().child("Friends/")
    }()
    
    private let friendRequestRef: DatabaseReference = {
        return Database.database().reference().child("FriendRequests/")
    }()
    
    private let receivedFriendRequestsRef: DatabaseReference? = {
        guard let id = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference().child("ReceivedFriendRequests/\(id)/")
    }()
    
    private let pendingFriendRequestsRef: DatabaseReference? = {
        guard let id = Auth.auth().currentUser?.uid else { return nil }
        return Database.database().reference().child("PendingFriendRequests/\(id)/")
    }()
    
    lazy var onlineFriends: [UserCacheInfo] = {
        var arr = [UserCacheInfo]()
        return arr
    }()
    
    lazy var offlineFriends: [UserCacheInfo] = {
        var arr = [UserCacheInfo]()
        return arr
    }()
    
    lazy var receivedFriendRequests: [FriendRequest] = {
        var arr = [FriendRequest]()
        return arr
    }()
    
    lazy var pendingFriendRequests: [FriendRequest] = {
        var arr = [FriendRequest]()
        return arr
    }()
    
    // stores all users cache info from friend request screen
    lazy var friendRequestUsersDict: [String: UserCacheInfo] = {
        var arr = [String: UserCacheInfo]()
        return arr
    }()
    
    // stores received friend request user id to its cell row
    lazy var receivedUserIdToCellRowDict: [String: Int] = {
        var arr = [String: Int]()
        return arr
    }()
    
    // stores pending friend request user id to its cell row
    lazy var pendingUserIdToCellRowDict: [String: Int] = {
        var arr = [String: Int]()
        return arr
    }()
    
    lazy var taskIdsToIndexPathCVDict: [Int: (Int, Int)] = {
        var dict = [Int: (Int, Int)]()
        return dict
    }()
    
    lazy var taskIdsToIndexPathTVDict: [Int: (Int, Int)] = {
        var dict = [Int: (Int, Int)]()
        return dict
    }()
    
    lazy var downloadSession: URLSession = {
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: nil)
        return session
    }()
    
    lazy var mediaManager: ImageManager = {
        let manager = ImageManager(downloadSession: downloadSession)
        return manager
    }()
    
   
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: FriendRequestTableViewCell.identifier,
                            bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: FriendRequestTableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.insertSections([0, 1], with: .automatic)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: FriendCollectionViewHeader.identifier, bundle: nil)
            collectionView.register(
                nib,
                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: FriendCollectionViewHeader.identifier)
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.addTarget(
                self,
                action: #selector(segmentedControlPressed(sender:)),
                for: .valueChanged)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        segmentedControl.selectedSegmentIndex = 0
       
        getUserFriends() {
            guard let onlineView = self.collectionView
                .supplementaryView(forElementKind: UICollectionElementKindSectionHeader,
                                   at: IndexPath(item: 0, section: 0)) as?
                FriendCollectionViewHeader else { return }
        
            guard let offlineView = self.collectionView
                .supplementaryView(forElementKind: UICollectionElementKindSectionHeader,
                                   at: IndexPath(item: 0, section: 1)) as?
                FriendCollectionViewHeader else { return }

            onlineView.friendsCountLabel.text = "\(self.onlineFriends.count)"
            offlineView.friendsCountLabel.text = "\(self.offlineFriends.count)"
        }
        
        getReceivedFriendRequests() { userCacheInfo, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = userCacheInfo else { return }
            self.updateTableViewRow(with: user, section: 0)
        }
        
        getPendingFriendRequests() { userCacheInfo, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let user = userCacheInfo else { return }
            self.updateTableViewRow(with: user, section: 1)
        }
    }
    
    @objc fileprivate func segmentedControlPressed(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Friends control pressed")
            tableView.isHidden = true
            collectionView.isHidden = false
            
        case 1:
            print("Friend requests pressed")
            collectionView.isHidden = true
            tableView.isHidden = false
        default:
            break
        }
    }
    
    @objc func acceptFriendRequestBtnPressed(sender: UIButton) {
        let friendRequest = receivedFriendRequests[sender.tag]
        guard let fromId = friendRequest.fromId else { return }
        guard let toId = friendRequest.toId else { return }
        
        // insert new friend to user's frinds list
        let toRef = friendRef.child("\(toId)/")
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: toRef, values: [fromId: "true"])
        
        // insert user's id to new friend's friends list
        let fromRef = friendRef.child("\(fromId)/")
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: fromRef, values: [toId: "true"])
        
        // update friend request accepted field
        let requestRef = friendRequestRef.child("\(friendRequest.id!)/")
        FirebaseCalls.shared
            .updateReferenceWithDictionary(ref: requestRef, values: ["accepted": "true"])
        
        // remove friend request pending id from new friend's pending request list
        let path = "\(pendingFriendRequestString)\(fromId)/\(friendRequest.id!)"
        FirebaseCalls.shared.removeReferenceValue(at: path)
        
        // remove accepted friend request from table view
        receivedFriendRequests.remove(at: sender.tag)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)],
                             with: .right)
        tableView.endUpdates()
    }
    
    fileprivate func getUserFriends(completion: @escaping (() -> Void)) {
        guard let uid = User.onlineUser.uid else { return }
        
        var counter = 0
        let ref = friendRef.child("\(uid)/")
        
        ref.observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
           
            FirebaseCalls.shared.getUserCacheInfo(for: id, completion: { (userCacheInfo, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let friend = userCacheInfo else { return }
                guard let status = friend.isOnline?.toBool() else { return }
                

                if status {
                    self.onlineFriends.append(friend)
                    let row = self.onlineFriends.count - 1
                    self.collectionView
                        .insertItems(at: [IndexPath(item: row, section: self.onlineSectionId)])
                } else {
                    self.offlineFriends.append(friend)
                    let row = self.offlineFriends.count - 1
                    self.collectionView
                        .insertItems(at: [IndexPath(item: row, section: self.offlineSectionId)])
                }
                counter += 1
                if counter == snapshot.childrenCount { completion() }
            })
            
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    fileprivate func updateTableViewRow(with user: UserCacheInfo, section: Int) {
        self.friendRequestUsersDict[user.uid!] = user
    
        let row: Int
        if section == 0 {
            row = self.receivedUserIdToCellRowDict[user.uid!] ?? 0
        } else {
            row = self.pendingUserIdToCellRowDict[user.uid!] ?? 0
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
    }
    
    fileprivate func getReceivedFriendRequests(completion:
        @escaping (UserCacheInfo?, Error?) -> Void) {
        receivedFriendRequestsRef?.observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            
            FirebaseCalls.shared.getFriendRequest(for: id) { (friendRequest, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let request = friendRequest else { return }
                guard let id = request.fromId else { return }
                guard let accepted = request.accepted?.toBool(), !accepted
                    else { return }
                
                self.receivedFriendRequests.append(request)
                
                self.tableView.beginUpdates()
                let row = self.receivedFriendRequests.count - 1
                self.receivedUserIdToCellRowDict[id] = row
                self.tableView.insertRows(at: [IndexPath(row: row, section: 0)],
                                          with: .none)
                self.tableView.endUpdates()
                
                FirebaseCalls.shared.getUserCacheInfo(for: id, completion: completion)
                
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
    
    fileprivate func getPendingFriendRequests(completion:
        @escaping (UserCacheInfo?, Error?) -> Void) {
        pendingFriendRequestsRef?.observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            
            FirebaseCalls.shared.getFriendRequest(for: id) { [unowned self] (friendRequest, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let request = friendRequest else { return }
                guard let id = request.toId else { return }
                self.pendingFriendRequests.append(request)
                
                self.tableView.beginUpdates()
                let row = self.pendingFriendRequests.count - 1
                self.pendingUserIdToCellRowDict[id] = row
                self.tableView.insertRows(at: [IndexPath(row: row, section: 1)],
                                          with: .none)
                self.tableView.endUpdates()
                
                FirebaseCalls.shared.getUserCacheInfo(for: id, completion: completion)
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
    }
}

// MARK: - UICollectionViewDelegate
extension FriendsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let (section, row) = (indexPath.section, indexPath.row)
        
        let user = section == 0 ? onlineFriends[row] : offlineFriends[row]
        let cell = collectionView.cellForItem(at: indexPath) as? FriendCollectionViewCell
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: vcIdentifier)
            as? GamerProfileViewController else { return }
        vc.userCacheInfo = user
        vc.userImage = cell?.friendImageView.image
        navigationController?.pushViewController(vc, animated: true)
        
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

// MARK: - UICollectionViewDataSource
extension FriendsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return onlineFriends.count
        } else {
            return offlineFriends.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCollectionViewCell
        let friend = indexPath.section == onlineSectionId ? onlineFriends[indexPath.item] : offlineFriends[indexPath.item]
        
        cell.friendUsernameLabel.text = friend.username
        
        if let url = friend.url, url != "" {
            let id = mediaManager .downloadImage(from: url)
            guard let taskId = id else { return cell }
            taskIdsToIndexPathCVDict[taskId] = (indexPath.item, indexPath.section)
        }
        cell.friendImageView.image = UIImage(named: "noAvatarImg")
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FriendsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerCell = collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                              withReuseIdentifier: FriendCollectionViewHeader.identifier,
                                              for: indexPath) as! FriendCollectionViewHeader
        if indexPath.section == 0 {
            headerCell.friendStatusLabel.text = "Online"
        }
        else {
            headerCell.friendStatusLabel.text = "Offline"
        }
        
        headerCell.friendsCountLabel.isHidden = true
        
        return headerCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50.0)
    }
}


// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (section, row) = (indexPath.section, indexPath.row)
        
        let request = section == 0 ? receivedFriendRequests[row] :
            pendingFriendRequests[row]
        let user = section == 0 ? friendRequestUsersDict[request.fromId!] : friendRequestUsersDict[request.toId!]
        let cell = tableView.cellForRow(at: indexPath)
            as? FriendRequestTableViewCell
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: vcIdentifier)
            as? GamerProfileViewController else { return }
        vc.userCacheInfo = user
        vc.userImage = cell?.friendImageView.image
        navigationController?.pushViewController(vc, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: - UITableViewDataSource
extension FriendsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return receivedFriendRequests.count
        } else {
            return pendingFriendRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestTableViewCell.identifier, for: indexPath)
            as? FriendRequestTableViewCell else { return UITableViewCell() }
        let (section, row) = (indexPath.section, indexPath.row)
        
        let friendRequest = section == 0 ? receivedFriendRequests[row] :
            pendingFriendRequests[row]
        let user = section == 0 ? friendRequestUsersDict[friendRequest.fromId!] : friendRequestUsersDict[friendRequest.toId!]
        
        if section == 0 {
            cell.friendUsernameLabel.text = user?.username
            cell.acceptFriendRequestBtn.tag = row
            cell.acceptFriendRequestBtn.addTarget(
                self,
                action: #selector(acceptFriendRequestBtnPressed(sender:)),
                for: .touchUpInside)
        } else {
            cell.friendUsernameLabel.text = user?.username
            cell.acceptFriendRequestBtn.isHidden = true
        }
        
        if let url = user?.url, !url.isEmpty {
            let id = mediaManager.downloadImage(from: url)
            guard let taskId = id else { return cell }
            taskIdsToIndexPathTVDict[taskId] = (row, section)
        } else {
            cell.friendImageView.image = UIImage(named: "noAvatarImg")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Received Friend Requests"
        } else {
            return "Pending Friend Requests"
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 6
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
        -> CGFloat {
        return 50.0
    }
}


extension FriendsViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let taskId = downloadTask.taskIdentifier
        
        do {
            let data = try Data(contentsOf: location)
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                if let (row, section) = self.taskIdsToIndexPathCVDict[taskId] {
                    let indexPath = IndexPath(row: row, section: section)
                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? FriendCollectionViewCell else { return }
                    cell.friendImageView.image = image
                }
                
                if let (row, section) = self.taskIdsToIndexPathTVDict[taskId] {
                    let indexPath = IndexPath(row: row, section: section)
                    guard let cell = self.tableView.cellForRow(at: indexPath)
                        as? FriendRequestTableViewCell else { return }
                    cell.friendImageView.image = image
                }
                
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






















